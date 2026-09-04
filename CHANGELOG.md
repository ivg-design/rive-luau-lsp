# Changelog

All notable changes to the Rive Luau LSP extension will be documented in this file.

## [1.2.1] - 2026-09-04

### Changed - Web 2.42 compatibility and agent tooling

- Update current-facing compatibility labels to Rive Web 2.42.0 while retaining the verified callable C++ `runtime-v0.1.344` boundary. Historical release entries remain unchanged.
- Correct the packaged Codex skill metadata to invoke `$rive-luau-lsp` explicitly and use the real `rive-luau-analyze` CLI workflow; remove the nonexistent `rive_luau_typecheck` function dependency and unsupported permissions claim.
- Audit the packaged Claude and Codex skills, source-checkout commands, release-archive commands, language-server launch examples, and wrapper help so they consistently use the shipped `rive-luau-analyze` and `rive-luau-lsp` commands with analyzer options before paths.
- Document the `EditorContext` rollout boundary: public Editor documentation lists `shader`, `canvas`, `gpuCanvas`, `features`, and `decodeImage`, but 1.2.1 does not promote them into the callable file-format declaration surface without target-Editor or shipped-source verification. Runtime `Context` declarations remain unchanged.

### Tests

- Re-run the focused and complete C++ suites, SolverV2 and all-feature-flag suites, wrapper behavior tests, strict Rive declaration fixtures, skill-package validation, package-input checks, and local macOS arm64 VSIX/CLI packaging.

## [1.2.0] - 2026-09-01

### Changed - canonical Web 2.41.1 / runtime-v0.1.344 toolchain

- Reconcile the fork with luau-lsp 1.69.0 and Luau 0.736 while preserving Rive's forced-strict configuration, imported `Data` namespace fallback, ancestor-walking bare `require()` resolution, local hover documentation, and warning-level lint behavior. Migrate the bundled declarations to Luau 0.736's `declare extern type` syntax and regenerate the tracked Luau patch.
- Add the stable Editor `FileFormat` and `TextFileFormat` surface: `FormatDocument`, scopes, tokens, diagnostics, completions, hover, `FormatView`, `FormatSurface`, editor theme/scroll/context data, and lifecycle callbacks.
- Declare the exact runtime-v0.1.344 `buffer.readf16`, `buffer.writef16`, `buffer.stridedcopy`, and `buffer.convert` helpers while preserving Luau 0.736's full built-in buffer table.
- Close released runtime gaps for `PointerEvent.previousPosition`/`timeStamp`, `AudioSource.duration`, gamepad forwarding on `Artboard`, `GPUBindGroupLayoutDesc.fragment`, `VertexBuffer`/`TriangleBuffer` mutation, `PathCommand`/`PathData`/`EnumValues` length, `Tester.blob`, optional named `ViewModel:instance`, and optional `Layout.resize(self, size, displayScale)`. Runtime 344 redispatches resize after a presenting-surface scale change and remains compatible with existing two-parameter Luau callbacks.
- Keep runtime-sensitive declarations conservative: empty `Blob.data` is `buffer?` and has no `asString`; `Canvas.image` and `GPUCanvas.image` are optional; `PropertyList` exposes `length`, numeric indexing, and source-backed mutations without phantom `count` or `item`; bare `Artboard` defaults to `Artboard<nil>`.
- Keep evidence tiers visible. `FileFormat` and `TextFileFormat` are stable Editor protocols; source-backed GPU declarations remain early access; `Context.log` and APIs labeled **Coming soon** remain annotated as Editor/reference surfaces. `Interpolator` callbacks stay optional to match runtime 344's linear fallbacks even though the current Editor reference lists them as required. Retired `drawCanvas`, unsupported `Animation:play`, and stale aggregate gamepad accessors remain rejected.
- Keep module resolution on authored `require("name")` values; host serialization and compiled-module identifiers are not declared as Luau globals or source-level module names.
- Make the CLI wrappers work both in source checkouts and flat release archives, require analyzer options before input paths, preserve analyzer process statuses, classify diagnostics consistently even when the formatter exits 0, suppress only the routine definitions-load info line, and make the LSP subcommand accept the wrapper's forced-strict launch option.
- Refuse to package a VSIX when its host native binary, Rive declarations, or Luau documentation are missing or empty.
- Map source and build roots out of GCC/Clang release binaries so packaged diagnostics do not disclose checkout or CI workspace locations.
- Correct public installation guidance: release archives are the default path, a source checkout must build the native server before use, the canonical repository is `ivg-design/rive-luau-lsp`, and analyzer-clean output is static evidence rather than Editor/runtime execution proof.
- Build and test one native binary per VSIX architecture in the release workflow, run the full C++ suite and strict Rive fixtures before publishing, and attach the required five native VSIX packages plus three host CLI archives. Each CLI archive includes both wrappers, definitions, docs, README, changelog, license, and attribution.

### Tests

- Add positive fixtures for the full FileFormat surface, the retained runtime-v0.1.316 additions, runtime-v0.1.344 Layout scale dispatch, and every script protocol; add negative coverage for retired, stale, unsupported, and host-only names; add direct regressions for Rive bare-require and strict-mode behavior plus shell tests for analyzer/LSP wrapper argument ordering, output, and exit propagation.

## [1.1.8] - 2026-08-14

### Fixed - runtime v0.1.262 scripting surface parity

- Remove the retired `Node.drawCanvas` callback; Canvas and GPUCanvas recording belongs in `draw(self, renderer)`.
- Add callable declarations and focused coverage for `Vector.xyz`, `Vector.cross3`, vector buffer writes, `Mat4.lookAt`, `Mat4.ortho`, ranged `GPUBuffer:write`, global ViewModels, and `ViewModel:getFont`/`getBlob`.
- Document library-scoped `context:blob` and `context:shader` references and preserve `GPUTextureView.format` as Early Access API surface.
- Match the live Editor reference for `Mat2D`/`Mat4` equality; `AudioSound.pause`/`resume`/`play`; `PointerType` and `PointerEvent.type`; `KeyPhase`; the exact `KeyboardEvent`, `TextInput`, `FocusEvent`, `ReportedEvent`, `ViewModelChange`, and `NoneEvent` names; and the full connected/event/disconnected gamepad payloads, ListenerContext accessors, and Node callbacks. A live Editor analyzer probe accepted the complete surface, and Mat2D/Mat4 equality additionally passed runtime assertions. The Editor labels the newer listener/gamepad types Coming soon, so callbacks and AudioSound transport retain analyzer/reference—not runtime execution—evidence. Compatible legacy `*Invocation` aliases and callbacks remain accepted where type-compatible. `ReportedEventInvocation.delaySeconds` remains separately nameable as a runtime dispatch payload, but `ListenerContext:asReportedEvent()` returns the current empty Editor `ReportedEvent`; negative coverage prevents the runtime-only field from leaking through that accessor.
- Make `bin/rive/rive-luau-analyze` return status 1 whenever analyzer diagnostics are emitted, status 0 only for a clean result, and preserve genuine analyzer process failures and their output. Correct repository-checkout documentation to the `bin/rive/` executable paths while retaining the flattened `./rive-luau-analyze` path used by macOS/Linux release archives.

## [1.1.7] - 2026-06-12

### Fixed - runtime-validated parity with the Rive Early Access editor

All findings validated live in the Rive editor (2026-06-11) with Test-protocol runtime checks and instrumented probe scripts, cross-checked against the editor's built-in scripting reference.

- **Add `Color.toFloat`** - converts a Color to a normalized `{r, g, b, a}` float table (0-1 range) for GPU `clearColor` usage; previously missing, so valid shader scripts failed analysis.
- **`Color` is now `export type Color = number`** - matches the editor's own definitions and runtime behavior (`type(Color.rgb(255, 0, 0)) == "number"`); raw packed hex literals like `0xFFFF0000` now type-check as valid Colors.
- **Close the `BlendMode` union** - removed the `| string` widening so blend-mode typos are caught in strict mode; default-mode behavior matches the editor (which does not flag them).
- **Add `Vector.__eq` and `Vector.z`** - the equality operator and read-only `z` component (plus `vec[3]` indexing) exist at runtime; previously caused false operator/property errors.
- **`ContourMeasure.next` is now optional** - typed `ContourMeasure?` to match its own documentation and runtime nil-at-last-contour behavior; iteration loops now require (and pass) the nil check.
- **Rewrite `Tester`/`Expectation` to the editor's calling convention** - `group`/`case` are plain dot-call functions and `expect` is the case-callback parameter (runtime-validated); the previous colon-method typing and global `expect` declaration rejected the editor's own canonical test example. Added the missing `Tests` and `Expect` types so `return function(): Tests` type-checks.
- **Correct `Node<T>` lifecycle hover docs** - `draw` is not required (draw-less scripts list, place, and run; validated in-editor); documented the playback-vs-design-mode advance model: `return false` unsubscribes from the playback advance loop only, `draw` fires independently on every repaint, and design-mode settle passes always pass `seconds = 0` and ignore the return value.
- **Document the general path mutation rule** - any mutation after drawing (not just `reset()`) requires waiting a frame before drawing the path again.
- **New test fixtures** - extended `rive_runtime_surface.luau` with the styling/vector/path surfaces and added `rive_test_protocol_surface.luau` covering the canonical Test-protocol script shape.

## [1.1.6] - 2026-06-03

### Fixed - GPU canvas image typing

- **Match Rive editor GPU compositing examples** - `GPUCanvas.image` is now typed as `Image`, so `renderer:drawImage(gpu.image, sampler, "srcOver", 1)` type-checks without a redundant nil guard.

## [1.1.5] - 2026-06-03

### Fixed - GPU shader scripting rollout parity

- **Add current shader lookup syntax** - `context:shader(name)` is now documented and typed as the current way to load WGSL shader assets; removed stale `context:loadShader()` and `context:preferredCanvasFormat()` from the API surface.
- **Add GPU resource constructors and descriptors** - added typed `GPUBuffer.new`, `GPUTexture.new`, `GPUSampler.new`, `GPUPipeline.new`, `GPUBindGroupLayout.new`, and `GPUBindGroup.new` descriptors with designer-focused hover guidance.
- **Align GPU canvas and render-pass signatures** - `GPUCanvas:resize(width, height)`, `GPUCanvas:beginRenderPass(...)`, `GPUBuffer:write(data, offset?)`, and render-pass draw/binding methods now match the current Rive C++ runtime.
- **Expose shader texture input helpers** - added `Image:view()` and `Node.drawCanvas` so shader scripts can type-check the full load, render-pass, and composite workflow.

## [1.1.4] - 2026-05-12

### Fixed - current Rive runtime scripting parity

- **Accept generic Artboard annotations** - `Artboard<nil>` and `Input<Artboard<nil>>` now type-check, matching the Rive editor and fixing nested/particle artboard scripts.
- **Fix Mat2D multiplication typing** - `Mat2D * Vector` now narrows to `Vector` and `Mat2D * Mat2D` narrows to `Mat2D`, eliminating false transform-chain errors.
- **Add current runtime API definitions** - added `Mat4`, typed listener payloads, Node keyboard/text callbacks, ViewModel image/index APIs, list removal APIs, canvas/GPU handles, Promise/async/decodeImage declarations, and `Interpolator<T>`.
- **Refresh hover docs for changed APIs** - updated outdated `context:getImage` and `context:artboard` examples, and documented new payloads and runtime additions.
- **Align local CLI wrappers with VS Code** - standalone `bin/rive` tools now use the bundled Rive definitions, SolverV2, and force-strict mode consistently.

## [1.1.3] - 2026-04-30

### Fixed — lint severity and duplicated hover content

- **Keep unused-code lints as warnings** — `LocalUnused`, `FunctionUnused`, and other Luau lint findings now stay `DiagnosticSeverity::Warning` even when Luau returns them through `lintResult.errors`.
- **Preserve lint quick fixes in both lint buckets** — quick fixes and "Remove all unused code" now inspect both lint warnings and lint errors.
- **Avoid duplicate VS Code provider matching** — the extension now registers a single Luau language selector instead of overlapping language and `**/*.luau` file-pattern selectors, and guards against duplicate client startup in one extension host.

## [1.1.2] - 2026-04-27

### Fixed — ListenerAction `performAction` protocol

- **Add `ListenerContext` type definition** — ListenerAction scripts can now type the current `performAction(self, listenerContext: ListenerContext)` callback without `Unknown type 'ListenerContext'` diagnostics.
- **Accept current and legacy ListenerAction callbacks** — `ListenerAction<T>` now supports `performAction` while preserving legacy `perform(self, pointerEvent: PointerEvent)` compatibility for older scripts.
- **Model ListenerContext event guards/accessors** — Added conservative `is...()` and `as...()` declarations for pointer, keyboard, text input, focus, reported event, ViewModel change, and none payloads.

## [1.0.10] - 2026-03-24

### Fixed — 100% type checking parity with Rive editor

Full parity audit using TypeCheckProbe.luau: every line the Rive editor accepts, the LSP now accepts. Every line the Rive editor flags, the LSP now flags.

- **Disable `forceStrictMode`** — The Rive editor does not use strict mode. `forceStrictMode: true` caused false positives (e.g., return type `Path` where `PathData` annotation exists). `LuauSolverV2` alone now handles and/or string literal narrowing correctly, making `forceStrictMode` unnecessary.
- **Add Vector arithmetic metamethods** — `__add`, `__sub`, `__mul`, `__div`, `__unm`. Vector uses Luau's native vector type with built-in arithmetic, but the definitions didn't declare the metamethods, causing false "Operator could not be applied" errors.
- **Add Mat2D `__mul` metamethod** — `mat * mat` (combine transforms) and `mat * vec` (transform point) now type-check correctly.
- **Mark Vector instance methods as `@deprecated`** — `v:length()`, `v:distance()`, etc. Rive editor shows deprecation warnings recommending static form (`Vector.length(v)`). LSP now matches.
- **Remove phantom `CommandType` global table** — Rive has no `CommandType` global; command types are string literals (`"moveTo"`, `"lineTo"`, etc.). The phantom `declare CommandType` caused the LSP to accept code that crashes at runtime.

## [1.0.9] - 2026-03-24

### Fixed — Path class missing `__len` operator

- **Add `__len` to `declare class Path`** — `#path` works at runtime (returns command count) but the type definitions didn't declare it, causing a false `TypeError: Operator '#' could not be applied to operand of type Path` in strict mode. Fix: added `function __len(self): number` to the Path class definition.

## [1.0.8] - 2026-03-19

### Added — CLI --force-strict-mode flag for full parity in analyze mode

- **`luau-lsp analyze --force-strict-mode`** — The analyze CLI now supports the same three overrides as the VS Code extension's `forceStrictMode` initialization option: strict mode, globals clearing (prevents anyType shadowing of definitions file), and lintErrors=false (lint stays as warnings). Usage: `luau-lsp analyze --flag:LuauSolverV2=true --force-strict-mode --definitions=@rive=rive-globals.d.luau file.luau`

## [1.0.7] - 2026-03-19

### Fixed — Lint warnings now show as yellow (not red) in VS Code

- **Reset lintErrors when forceStrictMode is active** — `.luaurc` `lintErrors: true` was promoting all lint warnings to `DiagnosticSeverity::Error` (red underlines), overriding the standard Luau behavior of yellow lint warnings. The Rive editor shows lint (LocalUnused, etc.) as warnings. Fix: `result.lintErrors = false` in `readConfigRec()` when `forceStrictMode = true`.

### LSP Modifications
- C++ mod #5c: `readConfigRec()` now sets `result.lintErrors = false` alongside `result.globals.clear()` and `result.mode = Strict` when `forceStrictMode = true`

## [1.0.6] - 2026-03-19

### Fixed — Complete Type Error Parity (all error classes)

- **Clear .luaurc globals when forceStrictMode is active** — Globals listed in `.luaurc` (e.g., `Paint`, `Color`, `Vector`) were being typed as `any` by `Frontend::getModuleEnvironment`, silently suppressing all type errors on those identifiers even in strict mode. Fix: `result.globals.clear()` in `readConfigRec()` when `forceStrictMode = true`, so the definitions file's typed bindings are used directly without `any` overrides. This is the root cause of Error Class 1 (and/or string literal widening) not being caught in VS Code.

### LSP Modifications
- C++ mod #5b: `readConfigRec()` now calls `result.globals.clear()` alongside `result.mode = Strict` when `forceStrictMode = true`

## [1.0.5] - 2026-03-18

### Fixed — Type Error Parity with Rive Editor (3 of 4 error classes)

- **Enable LuauSolverV2** — switched from `--no-flags-enabled` to `--flag:LuauSolverV2=true`. The Rive editor's type checker runs with SolverV2; the LSP now does too. This alone fixes cross-module type identity mismatches (`FadeTrimData from '0-65973' vs '0-65967'`), generic arithmetic errors on untyped parameters (`sub<a,a>`), and table literal missing-field errors.
- **Force strict mode** — added `forceStrictMode` initialization option (C++ mod #5: `WorkspaceFileResolver.forceStrictMode`). The LSP now overrides `.luaurc` `languageMode: nonstrict` to strict, matching the Rive editor's enforcement of string literal subtype checking. Fixes `and/or` expressions widening `"round" | "butt"` to `string`.
- **Cleaned up broken fflags** — removed `enableByDefault`/`sync` non-FFlag keys from initializationOptions that were silently failing JSON type parsing.

### LSP Modifications
- C++ mod #5: `WorkspaceFileResolver.forceStrictMode` field — when true, overrides post-`.luaurc` config mode to `Luau::Mode::Strict` in `readConfigRec()` and resets `defaultConfig.mode`
- `InitializationOptions.forceStrictMode` bool — parsed from client initialization options and applied to all workspace folders and the null workspace
- Both changes are no-op when `forceStrictMode = false`, so upstream luau-lsp behavior is fully preserved

## [1.0.4] - 2026-03-14

### Added
- **Data namespace type resolution** — `Input<Data.X>` now resolves in type annotations, matching Rive editor syntax
- `Data.X.new()` returns typed `__RiveDataViewModel` (ViewModel with dynamic property access)
- `self.character:getNumber("x")` returns `PropertyNumber?` on Data inputs (ViewModel methods available)
- Generic namespace fallback system via `TYPE_NAMESPACE_FALLBACKS` definitions metadata

### LSP Modifications
- New C++ modification (#4): `ImportedTypeNamespace` struct with `fallback` field in `Scope.h`
- `lookupImportedType()` now checks namespace fallback when specific member not found
- Metadata-driven `applyTypeNamespaceFallbacks()` — no hard-coded namespace strings in C++

### Changed
- `rive-globals.d.luau` updated with `__RiveDataViewModel`, `__RiveDataConstructor`, and `declare Data` types
- Definitions metadata header now includes `TYPE_NAMESPACE_FALLBACKS`

## [1.0.3] - 2026-03-13

### Added
- Standalone CLI tools (`bin/rive/rive-luau-analyze`, `bin/rive/rive-luau-lsp`) for agent and CI usage without VS Code
- Installable AI agent skill packages for Claude Code and OpenAI Codex (`skills/`)
- Agent integration documentation in README

### Changed
- README rewritten with CLI usage, agent skills install instructions, and updated project structure

## [1.0.2] - 2026-03-13

### Added
- Extension marketplace icon (Rive script logo)
- Repository link in extension manifest
- LICENSE bundled in VSIX package
- Marketplace README (`extension/README.md`)

### Changed
- Publisher ID updated to `IVGDesign`

## [1.0.1] - 2026-03-13

### Added
- Custom file icon for `.luau` files in the VS Code explorer
- Optional "Rive Luau Icons" file icon theme
- Enriched documentation for all enum types (BlendMode, PaintStyle, StrokeCap, StrokeJoin) with visual descriptions
- Enriched documentation for PaintDefinition, NodeReadData, NodeData, Listener
- Enriched documentation for Property system types (PropertyNumber, PropertyString, PropertyBoolean, PropertyColor, PropertyList, PropertyViewModel)
- Enriched documentation for DataValue types, Input/Output generics, AudioSource, ImageWrap, ImageFilter, ImageSampler
- Enriched documentation for CommandType, PathCommand, PathData, Tester, Expectation, DataContext, EnumValues, Trigger

## [1.0.0] - 2026-03-12

### Added
- Initial release of the Rive Luau VS Code extension
- Full Luau language server (luau-lsp) with Rive-specific modifications
- Complete Rive scripting API type definitions (`rive-globals.d.luau`) with educational hover documentation
- Comprehensive Luau standard library documentation (`luau-api-docs.json`) — 655 symbols rewritten for non-programmers
- Luau syntax highlighting (TextMate grammar) including Markdown code blocks
- Real-time diagnostics, type checking, autocomplete, hover tooltips, go-to-definition
- Ancestor-walk require resolution for Rive's module system

### Rive API Types Covered
- **Core:** Vector, Color, Mat2D
- **Drawing:** Path, Paint, Renderer, Gradient, PathMeasure, ContourMeasure, ImageSampler
- **Scene:** NodeData, NodeReadData, Artboard, Animation
- **Data Binding:** ViewModel, Property, PropertyList, DataContext, Context
- **Assets:** Image, Blob, AudioSource, AudioSound, Audio
- **Protocols:** Node, Layout, Converter, PathEffect, ListenerAction, TransitionCondition
- **Data Values:** DataValue, DataValueNumber, DataValueString, DataValueBoolean, DataValueColor
- **Events:** PointerEvent
- **Testing:** Tester, Expectation
- **Utilities:** Input, Output, late(), expect()

### LSP Modifications (from upstream luau-lsp)
- Ancestor-walk fallback for bare `require()` paths — walks up parent directories bounded by workspace root
- Removed "Learn More" external links from hover documentation output
- All documentation rendered locally without external dependencies
