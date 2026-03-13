# Rive Luau

**Language intelligence for Rive's Luau scripting environment** — rich tooltips, autocomplete, real-time diagnostics, and IntelliSense designed for artists and designers learning to code.

---

## Features

### Rich Educational Tooltips

Every type, method, property, and parameter has detailed hover documentation written in plain English — not terse technical jargon. Tooltips explain **what** things do, **why** you'd use them, and **how** with practical examples.

```
drawPath — "Render a shape on screen. This is the core drawing call.
You give it two things: path (what to draw) and paint (how it looks)."

clipPath — "Mask all future drawing to only appear inside this shape.
Like cutting a hole in paper — only the area inside is visible."

BlendMode — "Controls how overlapping shapes blend together —
like Photoshop layer blend modes."
```

### Autocomplete

Context-aware suggestions for:
- The entire **Rive scripting API** — Vector, Color, Path, Paint, Renderer, Mat2D, ViewModel, and 40+ more types
- All **Luau standard library** functions — math, string, table, bit32, coroutine, and more
- Your own variables, functions, and types

### Real-Time Diagnostics

Catches errors as you type:
- Type mismatches
- Missing required properties
- Undefined variables and functions
- Incorrect function arguments

### Go-to-Definition

Jump to where any symbol is defined with `Cmd+Click` / `Ctrl+Click`.

### Syntax Highlighting

Full Luau grammar support including syntax highlighting inside Markdown code blocks.

### Custom File Icon

`.luau` files display a custom Rive script icon in the VS Code explorer, tabs, and breadcrumbs.

---

## Rive API Coverage

Complete type definitions and documentation for:

| Category | Types |
|----------|-------|
| **Core** | `Vector`, `Color`, `Mat2D` |
| **Drawing** | `Path`, `Paint`, `Renderer`, `Gradient`, `PathMeasure`, `ContourMeasure`, `ImageSampler` |
| **Scene** | `NodeData`, `NodeReadData`, `Artboard`, `Animation` |
| **Data Binding** | `ViewModel`, `Property<T>`, `PropertyList`, `DataContext`, `Context` |
| **Assets** | `Image`, `Blob`, `AudioSource`, `AudioSound`, `Audio` |
| **Script Protocols** | `Node<T>`, `Layout<T>`, `Converter<T,I,O>`, `PathEffect<T>`, `ListenerAction<T>`, `TransitionCondition<T>` |
| **Events** | `PointerEvent` |
| **Testing** | `Tester`, `Expectation` |

## Luau Standard Library Coverage

655 documented symbols including:
- **math** — floor, ceil, clamp, lerp, sin, cos, noise, random, and 25+ more
- **string** — find, format, gsub, split, sub, and 12+ more
- **table** — insert, remove, sort, find, freeze, and 12+ more
- **Globals** — print, require, type, tostring, tonumber, assert, error, pcall, pairs, ipairs, and more
- **bit32, coroutine, debug, os, utf8, buffer** — full coverage

---

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `rive-luau.trace.server` | `"off"` | Traces communication between VS Code and the language server. Set to `"messages"` or `"verbose"` for debugging. |

---

## File Icon Theme

The extension automatically shows a custom icon for `.luau` files. For a dedicated icon theme, open the Command Palette (`Cmd+Shift+P`) → **"Preferences: File Icon Theme"** → **"Rive Luau Icons"**.

---

## Attribution

Built on open source software:

- **[Rive](https://rive.app)** — Copyright (c) 2020 Rive (MIT License)
- **[luau-lsp](https://github.com/JohnnyMorganz/luau-lsp)** — Copyright (c) 2022 JohnnyMorganz (MIT License)
- **[Luau](https://github.com/luau-lang/luau)** — Copyright (c) 2019-2025 Roblox Corporation; Copyright (c) 1994-2019 Lua.org, PUC-Rio (MIT License)

---

## Links

- [Source Code](https://github.com/ivg-design/rive-luau-lsp)
- [Changelog](https://github.com/ivg-design/rive-luau-lsp/blob/main/CHANGELOG.md)
- [Report Issues](https://github.com/ivg-design/rive-luau-lsp/issues)
