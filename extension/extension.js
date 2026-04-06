const { LanguageClient, TransportKind } = require("vscode-languageclient/node");
const vscode = require("vscode");
const path = require("path");
const os = require("os");

let client;

function activate(context) {
  const binaryName = os.platform() === "win32" ? "luau-lsp.exe" : "luau-lsp";
  const binaryPath = path.join(context.extensionPath, "bin", binaryName);
  const definitionsPath = path.join(
    context.extensionPath,
    "definitions",
    "rive-globals.d.luau"
  );

  const docsPath = path.join(
    context.extensionPath,
    "definitions",
    "luau-api-docs.json"
  );

  const serverOptions = {
    command: binaryPath,
    args: [
      "lsp",
      `--definitions=@rive=${definitionsPath}`,
      `--docs=${docsPath}`,
      "--flag:LuauSolverV2=true",
    ],
    transport: TransportKind.stdio,
  };

  const clientOptions = {
    documentSelector: [
      { scheme: "file", language: "luau" },
      { scheme: "file", pattern: "**/*.luau" },
    ],
    initializationOptions: {
      platform: { type: "standard" },
      types: { roblox: false },
      sourcemap: { enabled: false },
      forceStrictMode: true,
      fflags: { LuauSolverV2: "true" },
    },
  };

  client = new LanguageClient(
    "rive-luau",
    "Rive Luau Language Server",
    serverOptions,
    clientOptions
  );

  client.start();
}

function deactivate() {
  if (client) {
    return client.stop();
  }
}

module.exports = { activate, deactivate };
