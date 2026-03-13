# Attribution

This project builds on the work of several open source projects. We are grateful to their authors and contributors.

---

## Rive

Copyright (c) 2020 Rive

The Rive Luau scripting API type definitions and documentation in this project are based on Rive's official scripting API, the [LERP course documentation](https://rive.app/community/doc/scripting-overview/docbFP0MSVxL), and the [Rive runtime](https://github.com/rive-app/rive-runtime).

- **License:** MIT
- **Repository:** [https://github.com/rive-app/rive-runtime](https://github.com/rive-app/rive-runtime)
- **Website:** [https://rive.app](https://rive.app)

---

## Luau Language Server (luau-lsp)

Copyright (c) 2022 JohnnyMorganz

The core language server powering this extension is built on **[luau-lsp](https://github.com/JohnnyMorganz/luau-lsp)** by JohnnyMorganz. It provides the LSP protocol implementation, type checking, autocompletion, hover information, go-to-definition, diagnostics, and all other language intelligence features. Our fork adds Rive-specific modifications including ancestor-walk require resolution and documentation rendering adjustments.

- **License:** MIT
- **Repository:** [https://github.com/JohnnyMorganz/luau-lsp](https://github.com/JohnnyMorganz/luau-lsp)

---

## Luau

Copyright (c) 2019-2025 Roblox Corporation
Copyright (c) 1994-2019 Lua.org, PUC-Rio.

**[Luau](https://luau-lang.org)** is a fast, small, safe, gradually typed embeddable scripting language derived from Lua. It is used as the scripting language for Rive's runtime scripting environment.

- **License:** MIT
- **Repository:** [https://github.com/luau-lang/luau](https://github.com/luau-lang/luau)

---

## Lua

Copyright (c) 1994-2019 Lua.org, PUC-Rio.

**[Lua](https://www.lua.org)** is the language from which Luau is derived. Created by Roberto Ierusalimschy, Waldemar Celes, and Luiz Henrique de Figueiredo at PUC-Rio.

- **License:** MIT
- **Website:** [https://www.lua.org](https://www.lua.org)

---

## TextMate Grammar

The Luau syntax highlighting grammar (`Luau.tmLanguage.json`) is adapted from the luau-lsp project's VS Code extension, originally based on the Lua TextMate grammar.

- **Source:** [luau-lsp editors/code](https://github.com/JohnnyMorganz/luau-lsp/tree/main/editors/code)
- **License:** MIT

---

## VS Code Language Client

The extension uses Microsoft's **[vscode-languageclient](https://github.com/microsoft/vscode-languageserver-node)** library for LSP communication.

- **Author:** Microsoft Corporation
- **License:** MIT
