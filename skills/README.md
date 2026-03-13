# AI Agent Skills

Ready-to-use skill definitions for integrating the Rive Luau LSP with AI coding agents.

## Claude Code

| File | Purpose |
|------|---------|
| [`claude/CLAUDE.md`](claude/CLAUDE.md) | Drop-in project instructions — copy into your project's `CLAUDE.md` |
| [`claude/rive-luau-skill.md`](claude/rive-luau-skill.md) | Full skill reference — API types, workflow, patterns, and rules |

**Quick start:** Copy `claude/CLAUDE.md` content into your project's `CLAUDE.md` file. Update paths to match your local clone. Claude will automatically type-check scripts before delivering them.

## OpenAI Codex / Custom GPTs

| File | Purpose |
|------|---------|
| [`codex/rive-luau-tool.md`](codex/rive-luau-tool.md) | Tool definition, system instructions, and API examples |

**Includes:**
- JSON function tool definition for `rive_luau_typecheck`
- System prompt with all available types and scripting rules
- Python examples for both Assistants API and Responses API
