-- Positive acceptance fixture for the stable Editor FileFormat and
-- TextFileFormat protocols retrieved from the installed Rive editor.

local function parseText(_self: TextFileFormat, doc: FormatDocument): buffer?
    if doc.text == nil then
        return nil
    end
    return buffer.fromstring(doc.text)
end

local function highlight(
    _self: TextFileFormat,
    _doc: FormatDocument,
    _parsed: buffer?
): { FormatToken }
    local scopes: { FormatScope } = {
        "none", "keyword", "type", "literal", "number", "operator",
        "punctuation", "property", "string", "comment", "boolean", "nil",
        "interp", "function",
    }
    local tokens: { FormatToken } = {}
    for column, scope in scopes do
        table.insert(tokens, {
            line = 0,
            column = column - 1,
            scope = scope,
            length = 1,
        })
    end
    return tokens
end

local function diagnostics(
    _self: TextFileFormat,
    _doc: FormatDocument,
    _parsed: buffer?
): { FormatDiagnostic }
    return {
        {
            startLine = 0,
            startColumn = 0,
            endLine = 0,
            endColumn = 1,
            message = "Example warning",
            severity = "warning",
        },
    }
end

local function completions(
    _self: TextFileFormat,
    _doc: FormatDocument,
    line: number,
    column: number,
    _parsed: buffer?
): { FormatCompletion }
    return {
        {
            text = "replacement",
            startLine = line,
            startColumn = column,
            endLine = line,
            endColumn = column,
        },
    }
end

local function hover(
    _self: TextFileFormat,
    _doc: FormatDocument,
    line: number,
    column: number,
    _parsed: buffer?
): FormatHover?
    return {
        startLine = line,
        startColumn = column,
        endLine = line,
        endColumn = column + 1,
        preview = "symbol: string",
        documentation = "**Current symbol**",
    }
end

local function view(
    _self: TextFileFormat,
    doc: FormatDocument,
    editor: EditorContext,
    surface: FormatSurface,
    _parsed: buffer?
): FormatView?
    local image = editor:image("preview")
    local blob = editor:blob("fixture")
    local artboard = editor:artboard("Preview")
    local host = editor:hostArtboard("Preview")
    local theme = editor:theme()
    local themeFont = editor:themeFont()
    local defaultFont = editor:defaultFont()
    local codeFont = editor:codeFont()
    local scroll = editor:editorScroll()

    editor:openUrl("https://rive.app")
    editor:scrollTo(0, 0)
    editor:scrollEditorTo(0)
    editor:requestDraw()

    if scroll then
        print(
            scroll.percent,
            scroll.line,
            scroll.maxLine,
            scroll.cursorLine,
            scroll.cursorFraction
        )
    end
    local keywordStyle: EditorThemeStyle = theme.scopes.keyword
    print(
        surface.kind,
        doc.name,
        doc.extension,
        keywordStyle.color,
        keywordStyle.weight,
        theme.background,
        theme.divider,
        theme.dividerHighlight,
        theme.error,
        theme.warning,
        theme.lineNumber,
        theme.fontSize,
        theme.lineHeight,
        image,
        blob,
        artboard,
        host,
        themeFont,
        defaultFont,
        codeFont
    )

    local result: FormatView = {
        draw = function(_view, renderer, width, height)
            renderer:save()
            renderer:restore()
            print(width, height)
        end,
        measure = function(_view, viewportWidth, viewportHeight)
            return viewportWidth, viewportHeight
        end,
        advance = function(_view, seconds)
            return seconds >= 0
        end,
        textScrolled = function(_view, x, y, line, maxLine)
            print(x, y, line, maxLine)
        end,
        paneScrolled = function(_view, x, y)
            print(x, y)
        end,
        paneWheel = function(_view, dx, dy)
            print(dx, dy)
        end,
        pointerDown = function(_view, event)
            event:hit()
        end,
        pointerMove = function(_view, event)
            print(event.position)
        end,
        pointerUp = function(_view, event)
            print(event.id)
        end,
        documentChanged = function(_view, changed, parsed)
            print(changed.text, changed.bytes, parsed)
        end,
        selectionChanged = function(_view, line, column)
            print(line, column)
        end,
        dispose = function(_view)
            print("disposed")
        end,
    }
    return result
end

local textFormat: TextFileFormat = {
    name = "Example text",
    extensions = { "example" },
    parse = parseText,
    view = view,
    highlight = highlight,
    diagnostics = diagnostics,
    completions = completions,
    hover = hover,
    format = function(_self, doc, _parsed)
        return doc.text
    end,
}

local binaryFormat: FileFormat = {
    name = "Example binary",
    extensions = { "bin" },
    parse = function(_self, doc)
        return doc.bytes
    end,
}

return function(): TextFileFormat
    print(binaryFormat)
    return textFormat
end
