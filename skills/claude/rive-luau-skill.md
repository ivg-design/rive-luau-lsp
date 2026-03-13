# Rive Luau LSP — Claude Code Skill

## Overview

You have access to a local Rive Luau language server and type checker for validating, analyzing, and understanding Rive Luau scripts.

## Tools

### Type Checker

Validate any Rive Luau script for type errors, undefined variables, missing properties, and incorrect function arguments:

```bash
/path/to/rive-luau-lsp/bin/rive-luau-analyze <file-or-directory>
```

- **Exit code 0** = no errors, script is valid
- **Non-zero exit code** = errors found, read stderr for details
- Supports single files or entire directories
- Respects `.luaurc` configuration if present in the project

### Language Server

Start the full LSP server over stdio for real-time diagnostics, autocomplete, and hover information:

```bash
/path/to/rive-luau-lsp/bin/rive-luau-lsp
```

### Type Definitions

The complete Rive scripting API is defined in:

```
/path/to/rive-luau-lsp/definitions/rive-globals.d.luau
```

**Read this file before writing any Rive Luau code.** It contains every available type, method, property, and constructor with educational documentation in `---` doc comments. Key types include:

| Category | Types |
|----------|-------|
| **Core** | `Vector`, `Color`, `Mat2D` |
| **Drawing** | `Path`, `Paint`, `Renderer`, `Gradient`, `PathMeasure`, `ContourMeasure` |
| **Scene** | `NodeData`, `NodeReadData`, `Artboard`, `Animation` |
| **Data Binding** | `ViewModel`, `Property<T>`, `PropertyList`, `DataContext`, `Context` |
| **Assets** | `Image`, `Blob`, `AudioSource`, `AudioSound`, `Audio` |
| **Script Protocols** | `Node<T>`, `Layout<T>`, `Converter<T,I,O>`, `PathEffect<T>`, `ListenerAction<T>`, `TransitionCondition<T>` |
| **Events** | `PointerEvent` |
| **Testing** | `Tester`, `Expectation` |

### Standard Library Documentation

Educational documentation for all Luau standard library functions:

```
/path/to/rive-luau-lsp/definitions/luau-api-docs.json
```

Covers math, string, table, bit32, coroutine, debug, os, utf8, buffer, and all global functions (print, require, type, pcall, etc.).

## Required Workflow

When writing or modifying Rive Luau scripts, always follow this process:

1. **Read** `rive-globals.d.luau` to understand available APIs and their signatures
2. **Write** the Rive Luau script following the type definitions
3. **Validate** by running `rive-luau-analyze` on the script
4. **Fix** any reported errors — read the error messages carefully
5. **Re-validate** until exit code 0 with no errors
6. **Never deliver a script that hasn't passed type checking**

## Script Structure

Every Rive Luau script follows this pattern:

```lua
-- 1. Define your type with inputs, outputs, and internal state
type MyNode = {
    someInput: Input<number>,       -- read-only, bound in Rive editor
    someOutput: Output<number>,     -- written by script, read by runtime
    context: Context,               -- runtime bridge
    path: Path,                     -- internal state
    paint: Paint,                   -- internal state
}

-- 2. Implement lifecycle functions
function init(self: MyNode, context: Context): boolean
    self.context = context
    self.path = Path.new()
    self.paint = Paint.with({ color = Color.rgb(255, 0, 0) })
    return true  -- return false to disable
end

function advance(self: MyNode, seconds: number): boolean
    -- called every frame with delta time
    return true  -- return true to keep running
end

function draw(self: MyNode, renderer: Renderer)
    -- called every frame to render (keep pure — no state changes!)
    renderer:drawPath(self.path, self.paint)
end

-- 3. Return a factory function
return function(): Node<MyNode>
    return {
        init = init,
        advance = advance,
        draw = draw,
        context = late(),   -- assigned in init()
        path = late(),      -- assigned in init()
        paint = late(),     -- assigned in init()
    }
end
```

## Common Patterns

### Save/Restore for Transforms
```lua
renderer:save()
renderer:transform(Mat2D.withTranslation(100, 50))
renderer:transform(Mat2D.withRotation(math.rad(45)))
renderer:drawPath(path, paint)
renderer:restore()  -- MUST match every save()
```

### Clipping
```lua
renderer:save()
renderer:clipPath(maskPath)       -- restrict drawing area
renderer:drawPath(content, paint) -- only visible inside mask
renderer:restore()
```

### ViewModel Data Binding
```lua
function init(self, context)
    local vm = context:viewModel()
    if vm then
        self.score = vm:getNumber("score")
        self.name = vm:getString("playerName")
        self.score:addListener(function()
            print("Score changed:", self.score.value)
        end)
    end
    return true
end
```

### Path Construction
```lua
local path = Path.new()
path:moveTo(Vector.xy(0, 0))       -- start point
path:lineTo(Vector.xy(100, 0))     -- straight line
path:cubicTo(                       -- smooth curve
    Vector.xy(125, 0),              -- control out
    Vector.xy(150, 25),             -- control in
    Vector.xy(150, 50)              -- end point
)
path:close()                        -- connect back to start
```

## Important Rules

- **`draw()` must be pure** — no state changes, no side effects, only rendering calls
- **Every `save()` must have a matching `restore()`** — unbalanced calls corrupt rendering
- **Don't call `path:reset()` and `renderer:drawPath()` in the same frame** — wait one frame between them
- **`late()` marks fields assigned in `init()`** — required for type checking to pass
- **`Input<T>` values are read directly** — use `self.myInput`, NOT `self.myInput.value`
- **`Property<T>` values use `.value`** — use `self.myProp.value` to read/write
- **Rotation is in radians** — use `math.rad(degrees)` to convert
- **Y-axis points down** — positive Y = downward in screen coordinates
