#include "doctest.h"
#include "Fixture.h"
#include "Platform/RobloxPlatform.hpp"
#include "LuauFileUtils.hpp"

#include <algorithm>

using namespace Luau::LanguageServer;

TEST_SUITE_BEGIN("Definitions");

static std::string readRequiredFile(const std::string& path)
{
    auto contents = Luau::FileUtils::readFile(path);
    REQUIRE_MESSAGE(contents, "Unable to read " << path);
    return *contents;
}

TEST_CASE("use_platform_metadata_from_first_registered_definitions_file")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri(), std::nullopt);

    client.definitionsFiles.emplace("@roblox", "./tests/testdata/standard_definitions.d.luau");
    client.definitionsFiles.emplace("@roblox1", "./tests/testdata/extra_definitions_relying_on_mutations.d.luau");

    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.isReady = true;

    REQUIRE(workspace.definitionsFileMetadata);

    RobloxDefinitionsFileMetadata metadata = workspace.definitionsFileMetadata.value();
    REQUIRE(!metadata.SERVICES.empty());
    REQUIRE(!metadata.CREATABLE_INSTANCES.empty());
}

TEST_CASE("handles_definitions_files_relying_on_mutations")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);

    client.definitionsFiles.emplace("@roblox", "./tests/testdata/standard_definitions.d.luau");
    client.definitionsFiles.emplace("@roblox1", "./tests/testdata/extra_definitions_relying_on_mutations.d.luau");

    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.isReady = true;

    auto document = newDocument(workspace, "foo.luau", R"(
        local x: ExtraDataRelyingOnMutations
        local y = x.RigType
    )");

    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE(result.errors.empty());
}

TEST_CASE("dont_crash_when_mutating_a_definitions_file_that_does_not_contain_expected_state")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri(), std::nullopt);

    client.definitionsFiles.emplace("@roblox", "./tests/testdata/bad_standard_definitions.d.luau");

    workspace.setupWithConfiguration(defaultTestClientConfiguration());

    REQUIRE(workspace.definitionsFileMetadata);
}

TEST_CASE("support_disabling_global_types")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);

    auto config = defaultTestClientConfiguration();
    config.types.disabledGlobals = {
        "table",
    };

    workspace.setupWithConfiguration(config);
    workspace.isReady = true;

    auto document = newDocument(workspace, "foo.luau", R"(
        --!strict
        local x = string.split("", "")
        local y = table.insert({}, 1)
    )");

    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE_EQ(result.errors.size(), 1);

    auto err = Luau::get<Luau::UnknownSymbol>(result.errors[0]);
    REQUIRE(err);
    CHECK_EQ(err->name, "table");
    CHECK_EQ(err->context, Luau::UnknownSymbol::Context::Binding);
}

TEST_CASE("support_disabling_methods_in_global_types")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);

    auto config = defaultTestClientConfiguration();
    config.types.disabledGlobals = {
        "table.insert",
    };

    workspace.setupWithConfiguration(config);
    workspace.isReady = true;

    auto document = newDocument(workspace, "foo.luau", R"(
        --!strict
        local x = table.find({}, "value")
        local y = table.insert({}, 1)
    )");

    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE_EQ(result.errors.size(), 1);

    auto err = Luau::get<Luau::UnknownProperty>(result.errors[0]);
    REQUIRE(err);
    CHECK_EQ(Luau::toString(err->table), "typeof(table)");
    CHECK_EQ(err->key, "insert");
}

TEST_CASE("package_name_is_recorded_onto_the_loaded_types")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);

    client.definitionsFiles.emplace("@example", "./tests/testdata/standard_definitions.d.luau");

    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.isReady = true;

    auto document = newDocument(workspace, "foo.luau", R"(
        local x: Instance
    )");

    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    auto module = workspace.frontend.moduleResolver.getModule(workspace.fileResolver.getModuleName(document));
    REQUIRE(module);

    auto binding = module->getModuleScope()->linearSearchForBinding("x");
    REQUIRE(binding);

    auto ty = Luau::follow(binding->typeId);
    CHECK_EQ(ty->documentationSymbol, "@example/globaltype/Instance");

    auto ctv = Luau::get<Luau::ExternType>(ty);
    REQUIRE(ctv);
    CHECK_EQ(ctv->definitionModuleName, "@example");
}

TEST_CASE("support_disabling_methods_in_extern_types_globals")
{
    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);

    client.definitionsFiles.emplace("@roblox", "./tests/testdata/standard_definitions.d.luau");

    auto config = defaultTestClientConfiguration();
    config.types.disabledGlobals = {
        "game.BindToClose",
    };

    workspace.setupWithConfiguration(config);
    workspace.isReady = true;

    auto document = newDocument(workspace, "foo.luau", R"(
        --!strict
        game:BindToClose(function() end)
    )");

    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE_EQ(result.errors.size(), 1);

    auto err = Luau::get<Luau::UnknownProperty>(result.errors[0]);
    REQUIRE(err);
    CHECK_EQ(Luau::toString(err->table), "DataModel");
    CHECK_EQ(err->key, "BindToClose");
}

TEST_CASE_FIXTURE(Fixture, "type_functions_in_definition_files_work")
{
    ENABLE_NEW_SOLVER();

    loadDefinition("@test", R"(
        export type function foo(ty)
            return types.negationof(ty)
        end
    )");

    auto result = check(R"(
        local x: foo<number> = nil :: any
    )");
    REQUIRE(result.errors.empty());
}

static void checkRiveScriptFixture(const std::string& path)
{
    ScopedFastFlag sffNewSolver{FFlag::LuauSolverV2, true};

    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);
    client.definitionsFiles.emplace("@rive", "./extension/definitions/rive-globals.d.luau");

    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.isReady = true;

    auto document = newDocument(workspace, "rive_test.luau", readRequiredFile(path));
    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE_MESSAGE(result.errors.empty(), "Rive test fixture failed: " << path);
}

TEST_CASE("rive_definitions_accept_confetti_node_script")
{
    checkRiveScriptFixture("tests/testdata/rive_confetti_node.luau");
}

TEST_CASE("rive_definitions_cover_current_runtime_scripting_surface")
{
    checkRiveScriptFixture("tests/testdata/rive_runtime_surface.luau");
}

TEST_CASE("rive_definitions_cover_runtime_262_callable_surface")
{
    checkRiveScriptFixture("tests/testdata/rive_runtime_new_api_surface.luau");
}

TEST_CASE("rive_definitions_cover_live_editor_reference_parity_surface")
{
    checkRiveScriptFixture("tests/testdata/rive_editor_reference_parity_surface.luau");
}

TEST_CASE("rive_definitions_cover_gpu_shader_scripting_surface")
{
    checkRiveScriptFixture("tests/testdata/rive_gpu_shader_surface.luau");
}

TEST_CASE("rive_definitions_cover_test_protocol_surface")
{
    checkRiveScriptFixture("tests/testdata/rive_test_protocol_surface.luau");
}

TEST_CASE("rive_definitions_reject_removed_gpu_shader_api_names")
{
    ScopedFastFlag sffNewSolver{FFlag::LuauSolverV2, true};

    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);
    client.definitionsFiles.emplace("@rive", "./extension/definitions/rive-globals.d.luau");

    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.isReady = true;

    auto document = newDocument(workspace, "rive_removed_gpu_api.luau", R"(
--!strict
function init(self, context: Context): boolean
    local _shader = context:loadShader("old_name")
    local _format = context:preferredCanvasFormat()
    return true
end
)");
    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE_MESSAGE(result.errors.size() >= 2, "Removed GPU shader API names should not type-check");
}

TEST_CASE("rive_definitions_reject_retired_and_separate_legacy_surfaces")
{
    ScopedFastFlag sffNewSolver{FFlag::LuauSolverV2, true};

    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);
    client.definitionsFiles.emplace("@rive", "./extension/definitions/rive-globals.d.luau");

    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.isReady = true;

    auto document = newDocument(workspace, "rive_removed_draw_canvas.luau", R"(
--!strict
local node: Node<{}> = {}
local _legacy = node.drawCanvas

function checkReportedEvent(context: ListenerContext)
    local reported = context:asReportedEvent()
    if reported then
        local _legacyDelay = reported.delaySeconds
    end
end
)");
    auto result = workspace.frontend.check(workspace.fileResolver.getModuleName(document));
    REQUIRE_MESSAGE(result.errors.size() >= 2, "Retired drawCanvas and the legacy-only ReportedEvent.delaySeconds field should not type-check");
}

TEST_CASE("rive_definitions_cover_hover_and_completion_surface")
{
    ScopedFastFlag sffNewSolver{FFlag::LuauSolverV2, true};

    Client client;
    auto workspace = WorkspaceFolder(&client, "$TEST_WORKSPACE", Uri::file(*Luau::FileUtils::getCurrentWorkingDirectory()), std::nullopt);
    client.definitionsFiles.emplace("@rive", "./extension/definitions/rive-globals.d.luau");

    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.setupWithConfiguration(defaultTestClientConfiguration());
    workspace.frontend.setLuauSolverMode(Luau::SolverMode::New);
    workspace.isReady = true;

    auto [completionSource, completionPosition] = sourceWithMarker(R"(
local value = Vector.|
)");
    auto completionUri = newDocument(workspace, "rive_completion_surface.luau", completionSource);
    lsp::CompletionParams completionParams;
    completionParams.textDocument = lsp::TextDocumentIdentifier{completionUri};
    completionParams.position = completionPosition;
    auto completions = workspace.completion(completionParams, nullptr);

    auto xyz = std::find_if(completions.begin(), completions.end(), [](const lsp::CompletionItem& item) { return item.label == "xyz"; });
    REQUIRE(xyz != completions.end());
    REQUIRE(xyz->documentation);
    CHECK(xyz->documentation->value.find("3D") != std::string::npos);

    auto [hoverSource, hoverPosition] = sourceWithMarker(R"(
local value = Vector.|cross3(Vector.xyz(1, 0, 0), Vector.xyz(0, 1, 0))
)");
    auto hoverUri = newDocument(workspace, "rive_hover_surface.luau", hoverSource);
    lsp::HoverParams hoverParams;
    hoverParams.textDocument = lsp::TextDocumentIdentifier{hoverUri};
    hoverParams.position = hoverPosition;
    auto hover = workspace.hover(hoverParams, nullptr);

    REQUIRE(hover);
    CHECK(hover->contents.value.find("3D cross product") != std::string::npos);
}

TEST_SUITE_END();
