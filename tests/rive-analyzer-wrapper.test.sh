#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WRAPPER="${REPO_DIR}/bin/rive/rive-luau-analyze"
LSP_WRAPPER="${REPO_DIR}/bin/rive/rive-luau-lsp"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rive-wrapper-test.XXXXXX")"

cleanup() {
    rm -rf -- "${TEST_DIR}"
}
trap cleanup EXIT

FAKE_ANALYZER="${TEST_DIR}/fake-luau-lsp"
cat >"${FAKE_ANALYZER}" <<'SH'
#!/bin/bash
seen_formatter=false
for argument in "$@"; do
    case "${argument}" in
        --formatter=plain)
            seen_formatter=true
            ;;
        fixture.luau)
            if [ "${seen_formatter}" != true ]; then
                echo "analyzer option was forwarded after the fixture path" >&2
                exit 8
            fi
            ;;
    esac
done

case "${FAKE_ANALYZER_MODE:-clean}" in
    clean)
        echo "[INFO] Loading definitions file: @rive - /tmp/rive-globals.d.luau"
        exit 0
        ;;
    diagnostics)
        echo "[INFO] Loading definitions file: @rive - /tmp/rive-globals.d.luau"
        echo "fixture.luau:1:1-5: TypeError: example diagnostic"
        exit 0
        ;;
    failure)
        echo "analyzer process failed" >&2
        exit 7
        ;;
    lsp)
        printf '%s\n' "$*"
        exit 5
        ;;
    *)
        echo "unknown fake analyzer mode" >&2
        exit 9
        ;;
esac
SH
chmod 755 "${FAKE_ANALYZER}"

run_wrapper() {
    local mode="$1"
    local expected_status="$2"
    local expected_output="$3"
    local output
    local wrapper_status

    set +e
    output="$(
        FAKE_ANALYZER_MODE="${mode}" \
        RIVE_LUAU_LSP_BIN="${FAKE_ANALYZER}" \
        RIVE_LUAU_DEFS_FILE="${REPO_DIR}/extension/definitions/rive-globals.d.luau" \
        "${WRAPPER}" --formatter=plain fixture.luau 2>&1
    )"
    wrapper_status=$?
    set -e

    if [ "${wrapper_status}" -ne "${expected_status}" ]; then
        echo "${mode}: expected status ${expected_status}, got ${wrapper_status}" >&2
        echo "${output}" >&2
        exit 1
    fi
    if [ "${output}" != "${expected_output}" ]; then
        echo "${mode}: unexpected output" >&2
        printf 'expected: %s\nactual: %s\n' "${expected_output}" "${output}" >&2
        exit 1
    fi
}

run_wrapper clean 0 ""
run_wrapper diagnostics 1 "fixture.luau:1:1-5: TypeError: example diagnostic"
run_wrapper failure 7 "analyzer process failed"

set +e
lsp_output="$(
    FAKE_ANALYZER_MODE=lsp \
    RIVE_LUAU_LSP_BIN="${FAKE_ANALYZER}" \
    RIVE_LUAU_DEFS_FILE="${REPO_DIR}/extension/definitions/rive-globals.d.luau" \
    RIVE_LUAU_DOCS_FILE="${REPO_DIR}/extension/definitions/luau-api-docs.json" \
    "${LSP_WRAPPER}" --flag:RiveWrapperProbe=true 2>&1
)"
lsp_status=$?
set -e

if [ "${lsp_status}" -ne 5 ]; then
    echo "lsp: expected status 5, got ${lsp_status}" >&2
    echo "${lsp_output}" >&2
    exit 1
fi
case "${lsp_output}" in
    *"lsp --definitions=@rive="*" --docs="*" --flag:LuauSolverV2=true --force-strict-mode --flag:RiveWrapperProbe=true") ;;
    *)
        echo "lsp: wrapper did not forward the canonical arguments" >&2
        echo "${lsp_output}" >&2
        exit 1
        ;;
esac

ACTUAL_LSP="${REPO_DIR}/build/luau-lsp"
if [ -x "${ACTUAL_LSP}" ]; then
    actual_help="$(RIVE_LUAU_LSP_BIN="${ACTUAL_LSP}" "${LSP_WRAPPER}" --help 2>&1)"
    case "${actual_help}" in
        *"--force-strict-mode"*) ;;
        *)
            echo "lsp: built server did not accept the wrapper's strict-mode option" >&2
            echo "${actual_help}" >&2
            exit 1
            ;;
    esac
fi

echo "rive-wrapper-tests: analyzer and LSP exit-behavior cases passed"
