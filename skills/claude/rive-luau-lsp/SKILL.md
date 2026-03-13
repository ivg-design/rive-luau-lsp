---
name: rive-luau-lsp
description: Rive Luau type checker and language server. Use when writing, editing, debugging, or validating any Rive Luau script (.luau). Provides static analysis against the complete Rive scripting API (Vector, Color, Path, Paint, Renderer, Mat2D, ViewModel, Context, and 40+ types). Always validate scripts before delivering them.
allowed-tools: Bash, Read, Grep, Glob, Write, Edit
---

# Rive Luau LSP

You have access to a Rive Luau language server and type checker.

## Tools

### Type Check a Script

```bash
${CLAUDE_SKILL_DIR}/../../../bin/rive-luau-analyze <file.luau>
```

Exit code 0 = no errors. Non-zero = type errors in stderr. Fix all errors before delivering.

### Type Check a Directory

```bash
${CLAUDE_SKILL_DIR}/../../../bin/rive-luau-analyze <directory/>
```

### Read the API Reference

The complete Rive scripting API with documentation:

```bash
${CLAUDE_SKILL_DIR}/../../../definitions/rive-globals.d.luau
```

**Read this file before writing any Rive Luau code.** It defines every type, method, property, and constructor with educational `---` doc comments.

## Required Workflow

1. **Read** `rive-globals.d.luau` to understand available APIs
2. **Write** the script following the type definitions
3. **Run** `rive-luau-analyze` to validate
4. **Fix** any errors reported in stderr
5. **Re-validate** until exit code 0
6. **Never deliver a script that hasn't passed type checking**

## Available Types

| Category | Types |
|----------|-------|
| **Core** | `Vector`, `Color`, `Mat2D` |
| **Drawing** | `Path`, `Paint`, `Renderer`, `Gradient`, `PathMeasure`, `ContourMeasure`, `ImageSampler` |
| **Scene** | `NodeData`, `NodeReadData`, `Artboard`, `Animation` |
| **Data Binding** | `ViewModel`, `Property<T>`, `PropertyList`, `DataContext`, `Context` |
| **Assets** | `Image`, `Blob`, `AudioSource`, `AudioSound`, `Audio` |
| **Protocols** | `Node<T>`, `Layout<T>`, `Converter<T,I,O>`, `PathEffect<T>`, `ListenerAction<T>`, `TransitionCondition<T>` |
| **Events** | `PointerEvent` |
| **Testing** | `Tester`, `Expectation` |

## Script Structure

Every Rive Luau script follows this pattern:

```lua
type MyNode = {
    someInput: Input<number>,
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

function advance(self: MyNode, seconds: number): boolean
    return true
end

function draw(self: MyNode, renderer: Renderer)
    renderer:drawPath(self.path, self.paint)
end

return function(): Node<MyNode>
    return {
        init = init,
        advance = advance,
        draw = draw,
        context = late(),
        path = late(),
        paint = late(),
    }
end
```

## Key Rules

- **`draw()` must be pure** — rendering calls only, no state changes
- **Every `save()` must have a matching `restore()`**
- **Don't `path:reset()` and `renderer:drawPath()` the same path in one frame**
- **Use `late()`** for fields assigned in `init()`
- **`Input<T>`** reads directly: `self.myInput` (NOT `.value`)
- **`Property<T>`** uses `.value`: `self.myProp.value`
- **Rotation is in radians** — use `math.rad(degrees)`
- **Y-axis points down** — positive Y = downward

## Common Patterns

### Transform Stack
```lua
renderer:save()
renderer:transform(Mat2D.withTranslation(100, 50))
renderer:transform(Mat2D.withRotation(math.rad(45)))
renderer:drawPath(path, paint)
renderer:restore()
```

### Clipping
```lua
renderer:save()
renderer:clipPath(maskPath)
renderer:drawPath(content, paint)
renderer:restore()
```

### ViewModel Binding
```lua
local vm = context:viewModel()
if vm then
    self.score = vm:getNumber("score")
    self.score:addListener(function()
        print("Score:", self.score.value)
    end)
end
```
