const fs = require("fs");
const path = require("path");

const extensionRoot = path.resolve(__dirname, "..");
const binaryName = process.platform === "win32" ? "luau-lsp.exe" : "luau-lsp";
const requiredFiles = [
  path.join(extensionRoot, "bin", binaryName),
  path.join(extensionRoot, "definitions", "rive-globals.d.luau"),
  path.join(extensionRoot, "definitions", "luau-api-docs.json"),
];

for (const file of requiredFiles) {
  let stat;
  try {
    stat = fs.statSync(file);
  } catch {
    throw new Error(`Required VSIX input is missing: ${file}`);
  }
  if (!stat.isFile() || stat.size === 0) {
    throw new Error(`Required VSIX input is not a non-empty file: ${file}`);
  }
}

if (process.platform !== "win32") {
  fs.accessSync(requiredFiles[0], fs.constants.X_OK);
}

JSON.parse(fs.readFileSync(requiredFiles[2], "utf8"));
console.log(`VSIX inputs verified for ${binaryName}`);
