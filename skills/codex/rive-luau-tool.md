# Rive Luau LSP — OpenAI Codex / Custom GPT Tool Definition

## Tool Registration

Add this as a tool in your custom GPT, Codex agent, or Assistants API configuration.

### Function Tool Definition (JSON)

```json
{
  "type": "function",
  "function": {
    "name": "rive_luau_typecheck",
    "description": "Validates a Rive Luau script for type errors, undefined variables, missing properties, and incorrect function arguments. Loads the complete Rive scripting API (Vector, Color, Path, Paint, Renderer, Mat2D, ViewModel, Context, and 40+ more types). Returns exit code 0 if the script is valid, or error messages describing what needs to be fixed.",
    "parameters": {
      "type": "object",
      "properties": {
        "file_path": {
          "type": "string",
          "description": "Path to the .luau file to validate"
        }
      },
      "required": ["file_path"]
    }
  }
}
```

### Execution

When the tool is called, run:

```bash
/path/to/rive-luau-lsp/bin/rive-luau-analyze "$file_path" 2>&1
```

Return both stdout and stderr to the model. Exit code 0 means no errors.

---

## System Instructions

Add this to your agent's system prompt:

```
You have access to a Rive Luau type checker via the `rive_luau_typecheck` tool.

RIVE LUAU SCRIPTING RULES:
- Rive Luau is a scripting language for the Rive interactive design platform
- Scripts use the Luau language (a Lua derivative) with Rive-specific APIs
- The complete API reference is at: /path/to/rive-luau-lsp/definitions/rive-globals.d.luau

AVAILABLE TYPES:
Core: Vector, Color, Mat2D
Drawing: Path, Paint, Renderer, Gradient, PathMeasure, ContourMeasure, ImageSampler
Scene: NodeData, NodeReadData, Artboard, Animation
Data Binding: ViewModel, Property<T>, PropertyList, DataContext, Context
Assets: Image, Blob, AudioSource, AudioSound, Audio
Script Protocols: Node<T>, Layout<T>, Converter<T,I,O>, PathEffect<T>, ListenerAction<T>, TransitionCondition<T>
Events: PointerEvent
Testing: Tester, Expectation

SCRIPT STRUCTURE:
Every Rive Luau script must:
1. Define a type for its state (inputs, outputs, internal fields)
2. Implement lifecycle functions (init, advance, draw, etc.)
3. Return a factory function that creates protocol instances

REQUIRED WORKFLOW:
1. Read the type definitions to understand available APIs
2. Write the script
3. Call rive_luau_typecheck to validate
4. If errors are returned, fix them and re-validate
5. Never deliver a script that hasn't passed validation

KEY RULES:
- draw() must be pure — rendering calls only, no state changes
- Every save() must have a matching restore()
- Don't reset() and drawPath() a path in the same frame
- Use late() for fields assigned in init()
- Input<T> reads directly (self.input), Property<T> uses .value
- Rotation is in radians — use math.rad(degrees)
- Y-axis points down (positive Y = downward)
```

---

## Assistants API Example (Python)

```python
import openai

client = openai.OpenAI()

assistant = client.beta.assistants.create(
    name="Rive Luau Developer",
    instructions="You write Rive Luau scripts. Always validate with rive_luau_typecheck before delivering.",
    model="gpt-4o",
    tools=[
        {
            "type": "function",
            "function": {
                "name": "rive_luau_typecheck",
                "description": "Validate a Rive Luau script for type errors",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "file_path": {
                            "type": "string",
                            "description": "Path to the .luau file to validate"
                        }
                    },
                    "required": ["file_path"]
                }
            }
        }
    ]
)
```

---

## Responses API Example (Python)

```python
import openai

client = openai.OpenAI()

tools = [
    {
        "type": "function",
        "name": "rive_luau_typecheck",
        "description": "Validate a Rive Luau script for type errors against the full Rive API",
        "parameters": {
            "type": "object",
            "properties": {
                "file_path": {
                    "type": "string",
                    "description": "Path to the .luau file to validate"
                }
            },
            "required": ["file_path"]
        }
    }
]

response = client.responses.create(
    model="gpt-4o",
    input="Write a Rive Luau script that draws a rotating red square",
    tools=tools,
)
```

When the model calls `rive_luau_typecheck`, execute:

```python
import subprocess

result = subprocess.run(
    ["/path/to/rive-luau-lsp/bin/rive-luau-analyze", file_path],
    capture_output=True, text=True
)

tool_output = result.stdout + result.stderr
exit_code = result.returncode  # 0 = valid
```
