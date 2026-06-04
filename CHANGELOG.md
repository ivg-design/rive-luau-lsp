# Changelog

All notable changes to the Rive Luau LSP extension will be documented in this file.

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
- Standalone CLI tools (`bin/rive-luau-analyze`, `bin/rive-luau-lsp`) for agent and CI usage without VS Code
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
