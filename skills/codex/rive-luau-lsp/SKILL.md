---
name: rive-luau-lsp
description: Rive Luau type checker and language server for validating Rive scripting API usage. Triggers when writing, editing, debugging, or validating Rive Luau scripts. Targets Rive Web 2.41.1 and runtime-v0.1.344, with separately tiered Editor and source-backed surfaces.
---

# Rive Luau LSP

Use the canonical Rive Luau type checker for diagnostics. Its released callable target is Rive Web 2.41.1 / runtime-v0.1.344. Later canary signatures are not part of that target.

Use a prebuilt CLI release archive by default. A fresh repository checkout has no native binary: initialize the `luau` submodule, apply `patches/luau-rive-mods.patch`, and build `Luau.LanguageServer.CLI` before using the repository wrapper.

## Run Diagnostics

From an extracted macOS or Linux CLI release archive:

```bash
chmod 755 luau-lsp rive-luau-analyze rive-luau-lsp
./rive-luau-analyze --formatter=plain path/to/script.luau
./rive-luau-analyze --formatter=plain path/to/scripts/
```

From the root of a built source checkout:

```bash
./bin/rive/rive-luau-analyze --formatter=plain path/to/script.luau
```

From another working directory, use the wrapper's absolute checkout path, for example `/absolute/path/to/rive-luau-lsp/bin/rive/rive-luau-analyze --formatter=plain path/to/script.luau`. The wrapper resolves its binary and definitions from its own location, not the caller's working directory.

If the archive wrapper is installed on `PATH`, use `rive-luau-analyze` with the same arguments. Put every analyzer option before the first file or directory. `luau-lsp analyze` treats options placed after a path as more input paths.

Exit code 0 means no diagnostics. Exit code 1 means diagnostics were emitted. Other nonzero statuses indicate an analyzer or wrapper failure. Read the output instead of treating every nonzero status as a type error. Analyzer-clean output is static evidence only; it does not execute the script or prove Editor placement, runtime dispatch, export, drawing, event, or playback behavior.

## Start the Language Server

Configure an LSP client to start one of these commands over stdio:

```bash
./rive-luau-lsp                 # extracted release archive
./bin/rive/rive-luau-lsp        # built source checkout, from repository root
```

An LSP client may likewise use the source wrapper's absolute path from any working directory.

The wrapper adds the `lsp` subcommand, Rive definitions, local Luau docs, SolverV2, and forced strict mode. Do not append another `lsp` argument. Starting the server does not print one-shot diagnostics; use `rive-luau-analyze` for shell or CI checks.

The equivalent direct archive command is:

```bash
./luau-lsp lsp \
  --definitions=@rive=./rive-globals.d.luau \
  --docs=./luau-api-docs.json \
  --flag:LuauSolverV2=true \
  --force-strict-mode
```

## Read the API Before Writing

In a release archive, read `rive-globals.d.luau`. In a source checkout, read `extension/definitions/rive-globals.d.luau` and the relevant local Rive documentation. The declarations document supported members with `---` comments.

Use these evidence tiers when making API claims:

- **Released runtime:** callable wrappers verified against Web 2.41.1 / runtime-v0.1.344. That runtime embeds the `rive_0_734` Luau fork. The LSP's Luau 0.736 parser and type checker do not upgrade the target runtime. `Layout.resize` receives `(size, displayScale)`; existing two-parameter Luau callbacks ignore the extra argument and remain runtime-compatible.
- **Current Editor protocols:** `FileFormat` and `TextFileFormat`, including document, view, surface, token, diagnostic, completion, and hover support, match the current Editor scripting reference. Verify behavior in the target Editor.
- **Source-backed early access:** GPU declarations are backed by released runtime wrappers and local public Rive scripting docs, but a declaration does not prove that every Editor build exposes the feature. Use only members present in the declarations and the target Editor documentation.
- **Coming soon or canary:** annotated reference-only types are not runtime proof. Do not promote later source signatures without released runtime and public Luau/Editor evidence.

## Available Surface

Core: Vector, Color, Mat2D, Mat4, Promise, buffer half-float/stride/conversion helpers
Drawing: Path, PathCommand, PathData, Paint, Renderer, Gradient, PathMeasure, ContourMeasure, ImageSampler, Canvas, GPUCanvas
GPU: Shader, GPUBuffer, GPUTexture, GPUTextureView, GPUSampler, GPUPipeline, GPUBindGroupLayout, GPUBindGroup, GPURenderPass
Scene: NodeData, NodeReadData, Artboard<T>, Animation
Data Binding: ViewModel, Property<T>, PropertyImage, PropertyBlob, PropertyList, DataContext, Context, Data namespace
Assets: Image, Blob, Font, AudioSource, AudioSound, Audio
Protocols: Node<T>, Layout<T>, Converter<T,I,O>, PathEffect<T>, ListenerAction<T>, TransitionCondition<T>, Interpolator<T>, FileFormat, TextFileFormat
File-format support: FormatDocument, FormatView, FormatSurface, scopes, tokens, diagnostics, completions, hover, theme, scroll, and context callbacks
Data Values: DataValue, DataValueNumber, DataValueString, DataValueBoolean, DataValueColor
Events: PointerEvent, KeyboardEvent, TextInput, FocusEvent, ReportedEvent, ViewModelChange, NoneEvent, GamepadConnected, GamepadEvent, GamepadDisconnected, ListenerContext
Testing: Tests, Tester, Expect, Expectation

Script Modules use ordinary authored names in `require("name")` calls. Internal serialization identifiers are not Luau module names.

## Required Workflow

1. Read the relevant declaration and local protocol documentation.
2. Return the factory shape required by the selected protocol.
3. Run `rive-luau-analyze` with options before paths.
4. Fix every diagnostic and re-run until the command exits 0.
5. For behavioral claims, also run the script in the intended Rive Editor/runtime path.

Node scripts return `Node<T>` and can implement `init`, `advance`, and `draw`. File-format scripts return `FileFormat` or `TextFileFormat` and implement that protocol's callbacks; do not force them into the Node lifecycle. The source fixture `tests/testdata/rive_file_format_surface.luau` demonstrates the verified file-format surface.

```lua
type MyNode = {
    context: Context,
    path: Path,
    paint: Paint,
}

function init(self: MyNode, context: Context): boolean
    self.context = context
    self.path = Path.new()
    self.paint = Paint.with({ color = Color.rgb(255, 0, 0) })
    return true
end

function draw(self: MyNode, renderer: Renderer)
    renderer:drawPath(self.path, self.paint)
end

return function(): Node<MyNode>
    return {
        init = init,
        draw = draw,
        context = late(),
        path = late(),
        paint = late(),
    }
end
```

## Key Rules

- Treat `draw()` as the Node render phase. It may rebuild transient paths before their first draw and may issue declared Canvas/GPU Canvas work. The retired `drawCanvas` callback is invalid.
- Every `save()` must have a matching `restore()`.
- After drawing a path, do not mutate and draw it again until the next frame.
- Use `late()` for fields assigned in `init()`.
- `Input<T>` reads directly; `Property<T>` uses `.value`.
- Rotation is in radians, and positive Y points down.
