# Changelog

All notable changes to the Rive Luau LSP extension will be documented in this file.

## [1.0.1] - 2026-03-13

### Added
- Extension marketplace icon (Rive script logo)
- Custom file icon for `.luau` files in the VS Code explorer
- Optional "Rive Luau Icons" file icon theme
- Enriched documentation for all enum types (BlendMode, PaintStyle, StrokeCap, StrokeJoin) with visual descriptions
- Enriched documentation for PaintDefinition fields
- Enriched documentation for NodeReadData and NodeData with educational examples
- Enriched documentation for Property system types (PropertyNumber, PropertyString, PropertyBoolean, PropertyColor, PropertyList, PropertyViewModel)
- Enriched documentation for DataValue types with per-variant explanations
- Enriched documentation for Input/Output generic types
- Enriched documentation for AudioSource, ImageWrap, ImageFilter, ImageSampler
- Enriched documentation for CommandType, PathCommand, PathData
- Enriched documentation for Tester and Expectation test framework types
- Enriched documentation for DataContext, Listener, EnumValues, Trigger

### Changed
- Publisher ID updated to `IVGDesign`

## [1.0.0] - 2026-03-12

### Added
- Initial release of the Rive Luau VS Code extension
- Full Luau language server (luau-lsp) with Rive-specific modifications
- Complete Rive scripting API type definitions (`rive-globals.d.luau`) with educational hover documentation
- Comprehensive Luau standard library documentation (`luau-api-docs.json`) — 655 symbols rewritten for non-programmers
- Luau syntax highlighting (TextMate grammar)
- Luau syntax highlighting in Markdown code blocks
- Real-time diagnostics and type checking
- Autocomplete for all Rive API types and standard Luau library
- Hover tooltips with rich, beginner-friendly documentation
- Go-to-definition support
- Ancestor-walk require resolution (Rive resolves from script root, not file directory)

### Rive API Types Covered
- **Core types:** Vector, Color, Mat2D
- **Drawing API:** Path, Paint, Renderer, Gradient, PathMeasure, ContourMeasure, ImageSampler
- **Scene hierarchy:** NodeData, NodeReadData, Artboard, Animation
- **Data binding:** ViewModel, Property, PropertyList, DataContext, Context
- **Assets:** Image, Blob, AudioSource, AudioSound, Audio
- **Script protocols:** Node, Layout, Converter, PathEffect, ListenerAction, TransitionCondition
- **Data values:** DataValue, DataValueNumber, DataValueString, DataValueBoolean, DataValueColor
- **Events:** PointerEvent
- **Testing:** Tester, Expectation
- **Utilities:** Input, Output, late(), expect()

### LSP Modifications (from upstream luau-lsp)
- Ancestor-walk fallback for bare `require()` paths — walks up parent directories bounded by workspace root
- Removed "Learn More" external links from hover documentation output
- All documentation rendered locally without external dependencies
