# Changelog

All notable changes to the Rive Luau LSP extension will be documented in this file.

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
