# LERP Runtime Coverage Note - 2026-05-12

This note is for the separate LERP documentation agent. It summarizes the Rive
runtime scripting APIs observed on current `rive-runtime` upstream/main at
`b25a3221` (`runtime-v0.1.64`) that are not fully covered by the existing LERP
course material or that need a fresh validation pass.

## Runtime Sources To Review

Paths are relative to the `rive-runtime` repository root:

- `include/rive/lua/rive_lua_libs.hpp`
- `src/lua/math/lua_mat2d.cpp`
- `src/lua/math/lua_mat4.cpp`
- `src/lua/lua_listener_invocation.cpp`
- `src/lua/lua_properties.cpp`
- `src/lua/lua_scripted_context.cpp`
- `src/lua/lua_image_decode.cpp`
- `src/lua/lua_promise.cpp`
- `src/lua/renderer/lua_gpu.cpp`
- `src/scripted/scripted_drawable.cpp`
- `src/scripted/scripted_interpolator.cpp`
- `dev/defs/scripted/scripted_interpolator.json`

## Add Or Refresh In LERP

1. `Artboard<T>` inputs and instances
   - Document that the editor/runtime accepts generic artboard annotations such
     as `Input<Artboard<nil>>` and `Artboard<nil>`.
   - Show particle/nested artboard patterns using `artboard:instance()` and
     `artboard:instance(viewModel)`.
   - Avoid examples that imply `context:artboard(name)` exists unless the
     runtime adds that method.

2. `Mat2D` multiplication overloads
   - Document the two runtime branches: `Mat2D * Vector -> Vector` and
     `Mat2D * Mat2D -> Mat2D`.
   - Include transform-chain examples that remain type-clean:
     `Mat2D.withTranslation(pos) * Mat2D.withRotation(angle)`.

3. `Mat4`
   - Add a Mat4 reference page covering fields `m11` through `m44`, numeric
     indexes 1 through 16, column-major order, and methods:
     `invert`, `invertAffine`, `transpose`, `transformPoint`,
     `transformVec4`, `writeToBuffer`.
   - Cover static constructors/helpers:
     `identity`, `values`, `fromTranslation`, `fromScale`,
     `fromRotationX/Y/Z`, `perspective`, `perspectiveReverseZ`,
     `multiply`, `multiplyAffine`, `invert`, `invertAffine`.

4. Listener and drawable input payloads
   - Replace loose `any` payload docs with concrete invocation types:
     `KeyboardInvocation`, `TextInputInvocation`, `FocusInvocation`,
     `ReportedEventInvocation`, `ViewModelChangeInvocation`,
     `GamepadInvocation`, `NoneInvocation`.
   - Document listener guards/accessors:
     `isKeyboardEvent/asKeyboardEvent`, `isTextInput/asTextInput`,
     `isFocus/asFocus`, `isReportedEvent/asReportedEvent`,
     `isViewModelChange/asViewModelChange`, `isGamepad/asGamepad`,
     `isNone/asNone`.
   - Add Node script `keyboardEvent(self, event)` and
     `textEvent(self, event)` examples. Note that returning true stops
     propagation.

5. ViewModel property additions
   - Add `ViewModel:getImage(name) -> Property<Image>?`.
   - Add `ViewModel:getIndex() -> number`, with `-1` meaning not currently in a
     ViewModel list item.
   - Expand `PropertyList` docs to include `remove`, `removeAt`, `removeAllOf`,
     and `clear`, including 1-based index behavior for `removeAt`.

6. Context additions
   - Add `context:preferredCanvasFormat()`.
   - Add `context:features()` GPU capability report.
   - Add `context:canvas(options)` and basic `Canvas` workflow:
     `beginFrame`, draw with returned `Renderer`, `endFrame`, composite
     `canvas.image`.
   - Add `context:gpuCanvas(options)`, `context:loadShader(name)`, and a
     high-level GPU scripting section. This should be marked advanced and
     validated against `lua_gpu.cpp` before teaching concrete descriptors.
   - Add `context:decodeImage(buffer) -> Promise<DecodedImage>`.

7. Promises, `async`, and `await`
   - Add a Promise reference covering `Promise.new`, `resolve`, `reject`,
     `all`, `andThen`, `catch`, `finally`, `cancel`, `onCancel`, and
     `getStatus`.
   - Explain that `await(promise)` must run inside `async()` and returns
     `(ok, valueOrError)` rather than throwing.

8. Scripted interpolators
   - Add a new protocol page for scripted interpolators.
   - Document optional methods:
     `transform(self, factor) -> number` and
     `transformValue(self, valueFrom, valueTo, factor) -> number`.
   - Mention runtime fallback behavior: omitted or failing methods degrade to
     standard linear behavior.

9. Tooltip/examples cleanup
   - Replace old `context:getImage(...)` examples with `context:image(...)`.
   - Replace artboard examples that use `context:artboard(...)` with
     `Input<Artboard<...>>` examples.
   - Add small strict-checkable examples for each newly documented API so the
     LERP docs can be validated with `rive-luau-analyze`.

## Suggested Validation Artifacts

- A strict Luau sample for each protocol: Node, ListenerAction, Converter,
  PathEffect, TransitionCondition, and Interpolator.
- A runtime-surface sample that exercises `Mat4`, image properties, list
  removals, typed listener payloads, canvas, decodeImage, and Promise chaining.
- A confetti/nested-artboard sample using `Input<Artboard<nil>>` and
  `Mat2D * Vector`.
