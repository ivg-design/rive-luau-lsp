--#METADATA#{"CREATABLE_INSTANCES":[], "SERVICES":[]}

-- =============================================================================
-- Rive Luau Type Definitions v2.0.0
-- For use with luau-lsp (https://github.com/JohnnyMorganz/luau-lsp)
-- Complete Rive scripting API with rich documentation for hover tooltips.
-- =============================================================================

-- =============================================================================
-- CORE TYPES
-- =============================================================================

--- **A 2D point or direction** — the most common type in Rive scripting.
---
--- A Vector holds an `x` and `y` value. Use it for positions, sizes, directions, and offsets.
--- Vectors are **immutable** — you can't change x or y. Every operation returns a NEW vector.
---
--- **Creating vectors:**
--- ```lua
--- local pos = Vector.xy(100, 200)   -- a point at x=100, y=200
--- local zero = Vector.origin()       -- (0, 0)
--- ```
---
--- **Math operators work on vectors:**
--- ```lua
--- local sum = posA + posB            -- add two vectors
--- local moved = pos + Vector.xy(10, 0) -- shift right by 10
--- local scaled = pos * 2             -- double both x and y
--- local flipped = -pos               -- negate both components
--- ```
declare class Vector
    --- **The horizontal value.** Positive = right, negative = left.
    --- Read-only — use `Vector.xy()` to create a new vector with different values.
    x: number
    --- **The vertical value.** Positive = down, negative = up (screen coordinates).
    --- Read-only — use `Vector.xy()` to create a new vector with different values.
    y: number
    --- Access by index: `vec[1]` is x, `vec[2]` is y.
    [number]: number
    --- **How far this point is from (0,0).** Same as `Vector.length(v)`.
    function length(self): number
    --- Squared distance from origin. Faster than `length()` — use when comparing distances.
    function lengthSquared(self): number
    --- **Get the direction** as a unit vector (length = 1). Same as `Vector.normalized(v)`.
    function normalized(self): Vector
    --- **How far away** another point is, in pixels.
    function distance(self, other: Vector): number
    --- Squared distance to another point. Faster for comparisons.
    function distanceSquared(self, other: Vector): number
    --- **Dot product** — measures how much two vectors point in the same direction.
    --- Positive = same way, 0 = perpendicular, negative = opposite.
    function dot(self, other: Vector): number
    --- **Smoothly blend** between this vector and another.
    --- `t=0` = this vector, `t=0.5` = halfway, `t=1` = other vector.
    function lerp(self, other: Vector, t: number): Vector
end

--- **Create and work with 2D points and directions.**
---
--- Vectors are used everywhere — positions, offsets, scales, velocities.
--- ```lua
--- local pos = Vector.xy(100, 200)     -- create a point
--- local len = Vector.length(pos)       -- how far from origin
--- local dir = Vector.normalized(pos)   -- which direction
--- local mid = Vector.lerp(a, b, 0.5)  -- point halfway between a and b
--- ```
declare Vector: {
    --- **Create a 2D point** from x (horizontal) and y (vertical) values.
    --- This is the most common way to create positions, offsets, and sizes.
    --- ```lua
    --- local position = Vector.xy(100, 200)
    --- local offset = Vector.xy(10, -5) -- right 10, up 5
    --- local size = Vector.xy(width, height)
    --- ```
    xy: (x: number, y: number) -> Vector,

    --- **Create a zero vector** (0, 0). Useful as a default or starting point.
    origin: () -> Vector,

    --- **How far a point is from (0,0)** in pixels. For a direction vector, this
    --- is its speed/magnitude.
    --- ```lua
    --- local dist = Vector.length(Vector.xy(3, 4)) -- returns 5
    --- ```
    length: (v: Vector) -> number,

    --- Squared length — faster than `length()`. Use when you only need to compare
    --- distances (avoids expensive square root).
    --- ```lua
    --- if Vector.lengthSquared(v) < radius * radius then -- inside circle
    --- ```
    lengthSquared: (v: Vector) -> number,

    --- **Get the direction only**, ignoring distance. Returns a vector with length = 1.
    --- Useful when you need "which way" but not "how far."
    --- ```lua
    --- local direction = Vector.normalized(velocity) -- which way it's moving
    --- ```
    normalized: (v: Vector) -> Vector,

    --- **Distance between two points** in pixels.
    --- ```lua
    --- local dist = Vector.distance(playerPos, targetPos)
    --- if dist < 50 then -- they're close!
    --- ```
    distance: (a: Vector, b: Vector) -> number,

    --- Squared distance between two points. Faster than `distance()` for comparisons.
    distanceSquared: (a: Vector, b: Vector) -> number,

    --- **Dot product** — measures alignment between two directions.
    --- Returns a number: positive = same direction, 0 = perpendicular, negative = opposite.
    --- ```lua
    --- local facing = Vector.dot(forward, toTarget)
    --- if facing > 0 then -- target is in front
    --- ```
    dot: (a: Vector, b: Vector) -> number,

    --- **Cross product** — tells you which side `b` is relative to `a`.
    --- Positive = `b` is clockwise from `a`, negative = counterclockwise.
    --- The value is the area of the parallelogram formed by the two vectors.
    cross: (a: Vector, b: Vector) -> number,

    --- **Move a point** by adding a scaled direction. Shorthand for `a + b * scale`.
    --- Perfect for physics: `pos = Vector.scaleAndAdd(pos, velocity, deltaTime)`
    scaleAndAdd: (a: Vector, b: Vector, scale: number) -> Vector,

    --- **Reverse of scaleAndAdd.** Shorthand for `a - b * scale`.
    scaleAndSub: (a: Vector, b: Vector, scale: number) -> Vector,

    --- **Smoothly blend between two points.** The most useful animation function.
    --- - `t = 0` → returns `from` exactly
    --- - `t = 0.5` → returns the midpoint
    --- - `t = 1` → returns `to` exactly
    --- - Values between 0-1 give smooth transitions
    --- ```lua
    --- local mid = Vector.lerp(startPos, endPos, 0.5) -- halfway
    --- local moving = Vector.lerp(startPos, endPos, progress) -- animate over time
    --- ```
    lerp: (from: Vector, to: Vector, t: number) -> Vector,
}

--- **A color** with red, green, blue, and alpha (transparency) channels.
---
--- Each channel is 0-255 (like CSS/Photoshop). Colors are **immutable** —
--- changing a channel returns a NEW color, leaving the original unchanged.
---
--- ```lua
--- local red = Color.rgb(255, 0, 0)                -- solid red
--- local semiTransparent = Color.rgba(0, 0, 255, 128)  -- half-transparent blue
--- local faded = Color.opacity(red, 0.3)            -- 30% visible red
--- local blend = Color.lerp(red, blue, 0.5)         -- purple (halfway)
--- ```
declare class Color
end

--- **Create and manipulate colors.**
---
--- Colors use 0-255 for each channel (red, green, blue, alpha).
--- Alpha controls transparency: 255 = fully visible, 0 = invisible.
---
--- **Reading/changing channels** — call with 1 arg to read, 2 args to change:
--- ```lua
--- local r = Color.red(myColor)          -- read: returns 0-255
--- local newC = Color.red(myColor, 200)  -- change: returns NEW color
--- ```
declare Color: {
    --- **Create a color with transparency.** All values 0-255.
    --- - `r` = red, `g` = green, `b` = blue, `a` = alpha (transparency)
    --- - Alpha: 255 = fully visible, 128 = half transparent, 0 = invisible
    --- ```lua
    --- local solidRed = Color.rgba(255, 0, 0, 255)
    --- local ghostBlue = Color.rgba(0, 0, 255, 64) -- barely visible blue
    --- ```
    rgba: (r: number, g: number, b: number, a: number) -> Color,

    --- **Create a solid (fully visible) color.** Alpha is automatically 255.
    --- ```lua
    --- local red = Color.rgb(255, 0, 0)
    --- local white = Color.rgb(255, 255, 255)
    --- local black = Color.rgb(0, 0, 0)
    --- ```
    rgb: (r: number, g: number, b: number) -> Color,

    --- **Read or change the red channel** (0-255).
    --- One arg = read: `Color.red(c)` returns the red value.
    --- Two args = change: `Color.red(c, 200)` returns a new color with red set to 200.
    red: ((color: Color) -> number) & ((color: Color, value: number) -> Color),

    --- **Read or change the green channel** (0-255).
    --- `Color.green(c)` to read, `Color.green(c, 200)` to change.
    green: ((color: Color) -> number) & ((color: Color, value: number) -> Color),

    --- **Read or change the blue channel** (0-255).
    --- `Color.blue(c)` to read, `Color.blue(c, 200)` to change.
    blue: ((color: Color) -> number) & ((color: Color, value: number) -> Color),

    --- **Read or change the alpha channel** (0-255).
    --- Alpha controls transparency: 255 = solid, 0 = invisible.
    --- `Color.alpha(c)` to read, `Color.alpha(c, 128)` for half-transparent.
    alpha: ((color: Color) -> number) & ((color: Color, value: number) -> Color),

    --- **Read or change transparency** using 0.0-1.0 range (easier than 0-255 alpha).
    --- - 1.0 = fully visible, 0.5 = half transparent, 0.0 = invisible
    --- ```lua
    --- local faded = Color.opacity(myColor, 0.3) -- 30% visible
    --- ```
    opacity: ((color: Color) -> number) & ((color: Color, value: number) -> Color),

    --- **Smoothly blend between two colors.** Essential for color animations.
    --- - `t = 0` → returns `from`
    --- - `t = 0.5` → returns a 50/50 mix
    --- - `t = 1` → returns `to`
    --- ```lua
    --- local blended = Color.lerp(startColor, endColor, progress)
    --- ```
    lerp: (from: Color, to: Color, t: number) -> Color,
}

--- 2D affine transformation matrix (3x2 components).
---
--- **Fields:** `xx`, `xy`, `yx`, `yy` (rotation/scale), `tx`, `ty` (translation).
--- All fields are **read/write**.
---
--- **Operators:**
--- - `mat * Vector` — transform a point
--- - `mat * mat` — combine transforms (order matters: right is applied first)
--- - `==` — equality
---
--- **Example:**
--- ```lua
--- local move = Mat2D.withTranslation(100, 50)
--- local spin = Mat2D.withRotation(math.pi / 4)
--- local combined = move * spin -- first rotate, then translate
--- local worldPos = combined * localPoint
--- ```
declare class Mat2D
    --- X-axis scale component. Default: 1.
    xx: number
    --- X-axis shear component. Default: 0.
    xy: number
    --- Y-axis shear component. Default: 0.
    yx: number
    --- Y-axis scale component. Default: 1.
    yy: number
    --- X translation (horizontal position).
    tx: number
    --- Y translation (vertical position).
    ty: number
    --- Indexed access: mat[1] through mat[6] = xx, xy, yx, yy, tx, ty
    [number]: number
    --- Compute the inverse of this matrix. Returns nil if the matrix is singular (not invertible).
    --- ```lua
    --- local inv = mat:invert()
    --- if inv then
    ---     local localPoint = inv * worldPoint
    --- end
    --- ```
    function invert(self): Mat2D?
    --- Check if this matrix is the identity transform (no rotation, scale, or translation).
    function isIdentity(self): boolean
end

--- Static constructors for Mat2D.
---
--- **Common patterns:**
--- ```lua
--- local identity = Mat2D.identity()
--- local move = Mat2D.withTranslation(100, 50)
--- local rotate = Mat2D.withRotation(math.rad(45))
--- local scale = Mat2D.withScale(2, 2)
--- local combined = move * rotate * scale
--- ```
declare Mat2D: {
    --- Create a matrix from all 6 components: xx, xy, yx, yy, tx, ty.
    values: (xx: number, xy: number, yx: number, yy: number, tx: number, ty: number) -> Mat2D,

    --- Create an identity matrix (no transformation).
    identity: () -> Mat2D,

    --- Create a translation matrix. Accepts (x, y) or a Vector.
    --- ```lua
    --- local m = Mat2D.withTranslation(100, 50)
    --- ```
    withTranslation: ((x: number, y: number?) -> Mat2D) & ((pos: Vector) -> Mat2D),

    --- Create a rotation matrix from an angle in **radians**.
    --- Use `math.rad(degrees)` to convert from degrees.
    --- ```lua
    --- local m = Mat2D.withRotation(math.rad(45)) -- 45 degrees
    --- ```
    withRotation: (radians: number) -> Mat2D,

    --- Create a scale matrix. Accepts (sx, sy) or a Vector.
    --- ```lua
    --- local m = Mat2D.withScale(2, 0.5) -- stretch x, squish y
    --- ```
    withScale: ((sx: number, sy: number?) -> Mat2D) & ((scale: Vector) -> Mat2D),

    --- Create a matrix with both scale and translation in one call.
    withScaleAndTranslation: ((scale: Vector, translation: Vector) -> Mat2D) & ((sx: number, sy: number, tx: number, ty: number) -> Mat2D),

    --- Compute inverse of `input` and write into `output`. Returns true on success.
    --- More efficient than creating a new matrix — reuses `output`.
    invert: (output: Mat2D, input: Mat2D) -> boolean,
}

-- =============================================================================
-- DRAWING API
-- =============================================================================

--- **Controls how overlapping shapes blend together** — like Photoshop layer blend modes.
---
--- - `"srcOver"` — **Normal.** New content draws on top (default, use this most of the time).
--- - `"multiply"` — **Darken.** Colors multiply together — great for shadows and tinting.
--- - `"screen"` — **Lighten.** Opposite of multiply — great for glows and highlights.
--- - `"overlay"` — **Contrast.** Darkens darks and lightens lights — adds punch.
--- - `"darken"` — Keeps the darker of the two colors at each pixel.
--- - `"lighten"` — Keeps the lighter of the two colors at each pixel.
--- - `"colorDodge"` — Brightens the background based on the foreground — intense highlights.
--- - `"colorBurn"` — Darkens the background based on the foreground — intense shadows.
--- - `"hardLight"` — Like overlay but controlled by the top layer.
--- - `"softLight"` — Gentle version of hardLight — subtle contrast.
--- - `"difference"` — Subtracts colors — produces inverted/psychedelic effects.
--- - `"exclusion"` — Similar to difference but lower contrast.
--- - `"hue"` / `"saturation"` / `"color"` / `"luminosity"` — HSL component blending.
---
--- ```lua
--- paint.blendMode = "srcOver"   -- normal (default)
--- paint.blendMode = "multiply"  -- darken/shadow effect
--- paint.blendMode = "screen"    -- glow/highlight effect
--- ```
export type BlendMode =
    "srcOver"
    | "multiply"
    | "screen"
    | "overlay"
    | "darken"
    | "lighten"
    | "colorDodge"
    | "colorBurn"
    | "hardLight"
    | "softLight"
    | "difference"
    | "exclusion"
    | "hue"
    | "saturation"
    | "color"
    | "luminosity"
    | string

--- **How the shape is rendered** — filled solid or as an outline.
---
--- - `"fill"` — Fills the entire interior of the shape with color (default).
--- - `"stroke"` — Draws only the outline. Control width with `paint.thickness`.
---
--- ```lua
--- paint.style = "fill"    -- solid shape (default)
--- paint.style = "stroke"  -- outline only
--- ```
export type PaintStyle = "fill" | "stroke"

--- **How stroke endpoints look** — the shape at the start and end of an open line.
---
--- - `"butt"` — Flat cut exactly at the endpoint (default). No overshoot.
--- - `"round"` — Semicircle cap extends past the endpoint. Looks smooth.
--- - `"square"` — Flat cap that extends half the stroke width past the endpoint.
---
--- Only matters for open paths (not closed shapes like circles).
---
--- ```lua
--- paint.cap = "round"  -- smooth rounded endpoints
--- ```
export type StrokeCap = "round" | "butt" | "square"

--- **How stroke corners look** — the shape where two line segments meet.
---
--- - `"miter"` — Sharp pointed corner (default). Can look spiky on tight angles.
--- - `"round"` — Smooth rounded corner. Best for organic shapes.
--- - `"bevel"` — Flat diagonal cut at the corner. Clean, geometric look.
---
--- ```lua
--- paint.join = "round"  -- smooth rounded corners
--- ```
export type StrokeJoin = "round" | "bevel" | "miter"

--- **One color in a gradient transition.** Defines which color appears at which position.
---
--- - `position` — Where along the gradient (0.0 = start, 1.0 = end)
--- - `color` — The color at that position
---
--- ```lua
--- local stops = {
---     { position = 0, color = Color.rgb(255, 0, 0) },   -- red at start
---     { position = 0.5, color = Color.rgb(255, 255, 0) }, -- yellow in middle
---     { position = 1, color = Color.rgb(0, 0, 255) },   -- blue at end
--- }
--- ```
export type GradientStop = {
    position: number,
    color: Color,
}

--- Gradient fill for paint. Create with Gradient.linear() or Gradient.radial().
---
--- **Example:**
--- ```lua
--- local g = Gradient.linear(
---     Vector.xy(0, 0), Vector.xy(100, 0),
---     { { position = 0, color = Color.rgb(255, 0, 0) },
---       { position = 1, color = Color.rgb(0, 0, 255) } }
--- )
--- ```
declare class Gradient
end

--- Static constructors for Gradient.
declare Gradient: {
    --- Create a linear gradient between two points with color stops.
    --- ```lua
    --- local g = Gradient.linear(startPos, endPos, {
    ---     { position = 0, color = Color.rgb(255, 0, 0) },
    ---     { position = 0.5, color = Color.rgb(0, 255, 0) },
    ---     { position = 1, color = Color.rgb(0, 0, 255) },
    --- })
    --- ```
    linear: (from: Vector, to: Vector, stops: { GradientStop }) -> Gradient,

    --- Create a radial gradient from a center point with a radius and color stops.
    --- ```lua
    --- local g = Gradient.radial(center, 50, {
    ---     { position = 0, color = Color.rgba(255, 255, 255, 255) },
    ---     { position = 1, color = Color.rgba(255, 255, 255, 0) },
    --- })
    --- ```
    radial: (center: Vector, radius: number, stops: { GradientStop }) -> Gradient,
}

--- **Settings table for creating or copying a Paint.** Used by `Paint.with()` and `paint:copy()`.
---
--- Every field is optional — only set what you need, defaults handle the rest.
---
--- ```lua
--- local myPaint = Paint.with({
---     style = "stroke",         -- "fill" or "stroke"
---     color = Color.rgb(255, 0, 0),  -- any Color
---     thickness = 3,            -- stroke width in pixels
---     cap = "round",            -- endpoint shape
---     join = "round",           -- corner shape
---     blendMode = "srcOver",    -- how it blends with layers behind
---     feather = 0,              -- edge softness (0 = sharp)
--- })
--- ```
export type PaintDefinition = {
    --- `"fill"` or `"stroke"`. Default: `"fill"`.
    style: PaintStyle?,
    --- Shape color. Default: black.
    color: Color?,
    --- Stroke width in pixels (only matters when style = "stroke").
    thickness: number?,
    --- Endpoint shape for open strokes: `"butt"`, `"round"`, or `"square"`.
    cap: StrokeCap?,
    --- Corner shape where lines meet: `"miter"`, `"round"`, or `"bevel"`.
    join: StrokeJoin?,
    --- How this paint blends with content behind it. Default: `"srcOver"` (normal).
    blendMode: BlendMode?,
    --- Edge softness. 0 = sharp, higher = softer/glowing.
    feather: number?,
    --- Gradient fill. Set a Gradient for color transitions, or `false` to use solid color.
    gradient: (Gradient | false)?,
}

--- **Controls how your shapes look** — the color, fill, stroke, thickness, and blending.
---
--- Every `renderer:drawPath()` call needs a Paint. The Path says WHAT to draw,
--- the Paint says HOW it looks.
---
--- **Two styles:**
--- - `"fill"` (default) — solid filled shape
--- - `"stroke"` — outline only, with adjustable thickness
---
--- **Quick ways to create:**
--- ```lua
--- -- Easiest: define everything at once
--- local fill = Paint.with({ color = Color.rgba(255, 0, 0, 255) })
--- local stroke = Paint.with({
---     style = "stroke",
---     thickness = 3,
---     color = Color.rgb(0, 128, 255),
---     cap = "round",
--- })
---
--- -- Or create and modify
--- local p = Paint.new()   -- starts as black fill
--- p.color = Color.rgb(255, 255, 0)
--- p.style = "stroke"
--- p.thickness = 2
--- ```
declare class Paint
    --- `"fill"` (solid shape) or `"stroke"` (outline only). Default: `"fill"`.
    style: PaintStyle
    --- The color of this paint. Default: black. Change with `paint.color = Color.rgb(...)`.
    color: Color
    --- **Stroke width in pixels.** Only visible when `style = "stroke"`.
    --- Larger values = thicker outlines.
    thickness: number
    --- **How stroke lines end** at their endpoints.
    --- `"butt"` (flat cut), `"round"` (rounded), or `"square"` (extended flat).
    cap: StrokeCap
    --- **How stroke corners look** where two lines meet.
    --- `"miter"` (sharp point), `"round"` (smooth), or `"bevel"` (flat cut).
    join: StrokeJoin
    --- **How this paint blends** with content already on screen.
    --- `"srcOver"` (normal), `"screen"` (lighten), `"multiply"` (darken), etc.
    blendMode: BlendMode
    --- **Edge softness.** 0 = perfectly sharp edges, higher = softer/glowing.
    feather: number
    --- **Gradient fill.** Set a Gradient to fill with a color transition instead of solid color.
    --- Set to `false` or nil to go back to solid color.
    gradient: Gradient?
    --- **Make a copy of this paint** with optional changes.
    --- Great for creating variations without modifying the original.
    --- ```lua
    --- local highlight = basePaint:copy({ color = Color.rgb(255, 255, 0) })
    --- ```
    function copy(self, overrides: PaintDefinition?): Paint
end

--- **Create a new Paint** to control how shapes look when drawn.
---
--- ```lua
--- local p = Paint.new()           -- black fill (default)
--- local p = Paint.with({ ... })   -- create with specific properties
--- ```
declare Paint: {
    --- **Create a default Paint** — black fill. Modify properties after creation.
    --- ```lua
    --- local p = Paint.new()
    --- p.style = "stroke"
    --- p.color = Color.rgb(255, 0, 0)
    --- p.thickness = 3
    --- ```
    new: () -> Paint,

    --- **Create a Paint with specific properties** all at once.
    --- All fields are optional — anything you don't set uses the default.
    --- ```lua
    --- local stroke = Paint.with({
    ---     style = "stroke",
    ---     thickness = 2,
    ---     color = Color.rgb(0, 128, 255),
    ---     cap = "round",
    ---     join = "round",
    --- })
    --- ```
    with: (definition: PaintDefinition) -> Paint,
}

--- Measures the total length of a path and provides sampling along it.
--- Obtain via `path:measure()`. Treats entire path as one continuous curve.
---
--- **Example:**
--- ```lua
--- local m = path:measure()
--- local pos, tangent = m:positionAndTangent(m.length / 2)  -- midpoint
--- ```
declare class PathMeasure
    --- Total length of the path in pixels.
    length: number
    --- True if the path is a single closed contour.
    isClosed: boolean
    --- Get position and tangent direction at a distance along the path.
    --- Returns two Vectors: (position, tangent). Tangent is a unit vector.
    --- ```lua
    --- local pos, tan = measure:positionAndTangent(distance)
    --- ```
    function positionAndTangent(self, distance: number): (Vector, Vector)
    --- Transform a point from "path space" to world space.
    --- `point.x` = distance along path, `point.y` = perpendicular offset.
    --- Useful for placing objects along curves.
    --- ```lua
    --- local worldPos = measure:warp(Vector.xy(dist, offset))
    --- ```
    function warp(self, point: Vector): Vector
    --- Extract a segment of the path between two distances and append to `dest`.
    --- ```lua
    --- local segment = Path.new()
    --- measure:extract(0, measure.length * 0.5, segment, true)
    --- ```
    function extract(self, startDist: number, endDist: number, dest: Path, startWithMove: boolean?): ()
end

--- Measures individual contours (subpaths) within a path.
--- Obtain via `path:contours()`. Chain via `.next` to iterate all contours.
---
--- **Example:**
--- ```lua
--- local c = path:contours()
--- while c do
---     print("Contour length:", c.length, "closed:", c.isClosed)
---     c = c.next
--- end
--- ```
declare class ContourMeasure
    --- Length of this individual contour in pixels.
    length: number
    --- True if this contour is closed.
    isClosed: boolean
    --- Next contour in the path, or nil if this is the last one.
    --- Use to iterate: `while c do ... c = c.next end`
    next: ContourMeasure
    --- Get position and tangent at a distance along this contour.
    --- Returns (position, tangent) — tangent is a unit vector.
    function positionAndTangent(self, distance: number): (Vector, Vector)
    --- Transform a point from contour-local space to world space.
    --- `point.x` = distance along contour, `point.y` = perpendicular offset.
    function warp(self, point: Vector): Vector
    --- Extract a segment of this contour and append to `dest`.
    function extract(self, startDist: number, endDist: number, dest: Path, startWithMove: boolean?): ()
end

--- **The kind of drawing instruction** in a path command.
---
--- Each command in a path is one of these:
--- - `"moveTo"` — Pick up the pen, place it at a new point (1 point)
--- - `"lineTo"` — Draw a straight line to a point (1 point)
--- - `"quadTo"` — Draw a simple curve (2 points: control + end)
--- - `"cubicTo"` — Draw an S-curve (3 points: controlOut + controlIn + end)
--- - `"close"` — Connect back to the start (0 points)
--- - `"none"` — Empty/invalid command
export type CommandType = "none" | "moveTo" | "lineTo" | "quadTo" | "cubicTo" | "close"

--- **Enum table for command type strings.** Use for comparing command types:
--- ```lua
--- if cmd.type == CommandType.cubicTo then
---     -- handle curve
--- end
--- ```
declare CommandType: {
    none: "none",
    moveTo: "moveTo",
    lineTo: "lineTo",
    quadTo: "quadTo",
    cubicTo: "cubicTo",
    close: "close",
}

--- **One drawing instruction inside a path** — move, line, curve, or close.
---
--- Each command has a `type` and control points accessed by index.
--- The number of points depends on the command type:
---
--- | Type | Points | Meaning |
--- |------|--------|---------|
--- | `"moveTo"` | 1 | `cmd[1]` = destination |
--- | `"lineTo"` | 1 | `cmd[1]` = line endpoint |
--- | `"quadTo"` | 2 | `cmd[1]` = control, `cmd[2]` = endpoint |
--- | `"cubicTo"` | 3 | `cmd[1]` = controlOut, `cmd[2]` = controlIn, `cmd[3]` = endpoint |
--- | `"close"` | 0 | no points needed |
---
--- ```lua
--- for i, cmd in ipairs(pathData) do
---     if cmd.type == "lineTo" then
---         local endPoint = cmd[1]
---         print("Line to:", endPoint.x, endPoint.y)
---     end
--- end
--- ```
export type PathCommand = {
    --- **What kind of command** this is (moveTo, lineTo, quadTo, cubicTo, close).
    type: CommandType,
    --- **Control points.** Index with `cmd[1]`, `cmd[2]`, `cmd[3]`.
    --- Each is a Vector. Count depends on command type (use `#cmd`).
    [number]: Vector,
}

--- Indexed collection of PathCommand objects. Used as input in PathEffect scripts.
--- Supports `#pathData` for count and `ipairs(pathData)` for iteration.
---
--- **Example (in a PathEffect):**
--- ```lua
--- function update(self, pathData, node)
---     for i, cmd in ipairs(pathData) do
---         if cmd.type == "lineTo" then
---             local point = cmd[1]
---             -- modify or rebuild geometry
---         end
---     end
--- end
--- ```
export type PathData = {
    contours: (self: PathData) -> ContourMeasure?,
    measure: (self: PathData) -> PathMeasure,
    [number]: PathCommand,
}

--- **A shape you can draw on screen.** Paths are the building blocks of all
--- custom drawing in Rive scripting.
---
--- Think of a Path like an invisible pen on paper:
--- 1. `moveTo()` — pick up the pen and place it somewhere
--- 2. `lineTo()` — draw a straight line to a new point
--- 3. `cubicTo()` — draw a smooth curve
--- 4. `close()` — connect back to where you started
--- 5. Pass it to `renderer:drawPath(path, paint)` to make it visible
---
--- ```lua
--- -- Draw a triangle
--- local path = Path.new()
--- path:moveTo(Vector.xy(50, 0))    -- top
--- path:lineTo(Vector.xy(100, 100)) -- bottom right
--- path:lineTo(Vector.xy(0, 100))   -- bottom left
--- path:close()                      -- back to top
---
--- renderer:drawPath(path, myPaint)
--- ```
declare class Path
    --- **Pick up the pen and place it at `point`** without drawing anything.
    --- This starts a new subpath. Always call this before lineTo/cubicTo.
    function moveTo(self, point: Vector): ()
    --- **Draw a straight line** from the current pen position to `point`.
    --- ```lua
    --- path:moveTo(Vector.xy(0, 0))
    --- path:lineTo(Vector.xy(100, 0)) -- horizontal line to the right
    --- ```
    function lineTo(self, point: Vector): ()
    --- **Draw a simple curve** from current position through `control` to `endPoint`.
    --- The curve bends toward the control point but doesn't pass through it.
    function quadTo(self, control: Vector, endPoint: Vector): ()
    --- **Draw a smooth S-curve** using two control points.
    --- This gives you the most control over curve shape.
    ---
    --- - `controlOut` — direction the curve leaves from
    --- - `controlIn` — direction the curve arrives at
    --- - `endPoint` — where the curve ends
    ---
    --- ```lua
    --- path:cubicTo(
    ---     Vector.xy(25, 50),   -- pulls curve down-left
    ---     Vector.xy(75, 50),   -- pulls curve down-right
    ---     Vector.xy(100, 0)    -- end point
    --- )
    --- ```
    function cubicTo(self, controlOut: Vector, controlIn: Vector, endPoint: Vector): ()
    --- **Close the shape** by drawing a straight line back to the last moveTo point.
    --- Call this to make a closed shape (triangle, polygon, etc).
    function close(self): ()
    --- **Erase everything** in this path, making it empty again.
    --- Warning: don't call reset() and drawPath() in the same frame — wait one frame.
    function reset(self): ()
    --- **Combine two paths together.** Adds all geometry from `other` into this path.
    --- Optionally apply a transform (move/rotate/scale) to the added geometry.
    --- ```lua
    --- path:add(otherPath, Mat2D.withTranslation(50, 0)) -- add shifted copy
    --- ```
    function add(self, other: PathData | Path, transform: Mat2D?): ()
    --- **Get the total length** of this path in pixels. Returns a PathMeasure
    --- that lets you sample positions, tangents, and extract segments.
    --- ```lua
    --- local m = path:measure()
    --- local halfway = m.length / 2
    --- local pos, tangent = m:positionAndTangent(halfway)
    --- ```
    function measure(self): PathMeasure
    --- **Iterate individual subpaths.** Returns the first contour, chain with `.next`.
    --- ```lua
    --- local c = path:contours()
    --- while c do print(c.length) ; c = c.next end
    --- ```
    function contours(self): ContourMeasure?
end

--- **Create a new empty Path** — your starting point for drawing custom shapes.
---
--- After creating, build the shape with moveTo/lineTo/cubicTo/close,
--- then draw it with `renderer:drawPath(path, paint)`.
---
--- ```lua
--- local path = Path.new()
--- path:moveTo(Vector.xy(0, 0))
--- path:lineTo(Vector.xy(100, 50))
--- path:close()
--- ```
declare Path: {
    --- **Create a new empty Path** ready for drawing commands.
    --- ```lua
    --- local path = Path.new()
    --- ```
    new: () -> Path,
}

--- GPU renderer passed to `draw()`. Provides path drawing, image rendering,
--- and a transform/clip stack.
---
--- **Important:** Always pair `save()` with `restore()`. Unbalanced calls cause rendering bugs.
---
--- **Transform stack example:**
--- ```lua
--- function draw(self, renderer)
---     renderer:save()
---     renderer:transform(Mat2D.withTranslation(100, 50))
---     renderer:transform(Mat2D.withRotation(self.angle))
---     renderer:drawPath(self.path, self.paint)
---     renderer:restore()
--- end
--- ```
---
--- **Clipping example:**
--- ```lua
--- renderer:save()
--- renderer:clipPath(maskPath)      -- restrict drawing area
--- renderer:drawPath(content, paint) -- only visible inside mask
--- renderer:restore()               -- remove clip
--- ```
declare class Renderer
    --- **Render a shape on screen.** This is the core drawing call in Rive scripting.
    ---
    --- You give it two things:
    --- - **path** — the shape outline (what to draw)
    --- - **paint** — the visual style (how it looks — color, fill/stroke, thickness)
    ---
    --- Nothing appears on screen until you call this. You can draw multiple
    --- paths per frame — they layer on top of each other in order.
    ---
    --- ```lua
    --- -- Draw a red triangle
    --- local tri = Path.new()
    --- tri:moveTo(Vector.xy(0, 100))
    --- tri:lineTo(Vector.xy(50, 0))
    --- tri:lineTo(Vector.xy(100, 100))
    --- tri:close()
    ---
    --- local red = Paint.with({ color = Color.rgba(255, 0, 0, 255) })
    --- renderer:drawPath(tri, red)
    --- ```
    function drawPath(self, path: Path, paint: Paint): ()
    --- **Display an image on screen** with filtering, blending, and transparency.
    ---
    --- - **image** — loaded via `context:getImage("name")`
    --- - **sampler** — controls how the image is filtered/tiled
    --- - **blendMode** — how it blends with what's behind (`"srcOver"` is normal)
    --- - **opacity** — 0.0 (invisible) to 1.0 (fully visible)
    ---
    --- ```lua
    --- local img = context:getImage("myTexture")
    --- local sampler = ImageSampler("clamp", "clamp", "bilinear")
    --- renderer:drawImage(img, sampler, "srcOver", 0.8) -- 80% opacity
    --- ```
    function drawImage(self, image: Image, sampler: ImageSampler, blendMode: BlendMode, opacity: number): ()
    --- Draw an image warped onto a triangle mesh. Advanced — used for distortion effects.
    function drawImageMesh(self, image: Image, sampler: ImageSampler, vertices: VertexBuffer, uvs: VertexBuffer, triangles: TriangleBuffer, blendMode: BlendMode, opacity: number): ()
    --- **Bookmark the current position/rotation/clip state** so you can return to it later.
    ---
    --- Think of it like "remember where I am." After save(), you can move, rotate,
    --- or clip freely — then call restore() to snap back.
    ---
    --- **IMPORTANT:** Every save() MUST have a matching restore(). Forgetting
    --- restore() causes all subsequent drawing to be wrong.
    ---
    --- ```lua
    --- renderer:save()                -- remember current state
    ---     renderer:transform(...)    -- move/rotate
    ---     renderer:drawPath(...)     -- draw in new position
    --- renderer:restore()             -- snap back to saved state
    --- ```
    function save(self): ()
    --- **Return to the previously saved state.** Undoes all transform() and clipPath()
    --- calls made since the matching save().
    ---
    --- Always call this after save() — they work as a pair.
    function restore(self): ()
    --- **Move, rotate, or scale everything drawn after this call.**
    ---
    --- Transforms stack — calling transform() twice applies both.
    --- Use save/restore to limit the effect.
    ---
    --- ```lua
    --- renderer:save()
    --- renderer:transform(Mat2D.withTranslation(100, 50)) -- shift right & down
    --- renderer:transform(Mat2D.withRotation(math.rad(45))) -- then rotate 45 deg
    --- renderer:drawPath(path, paint) -- drawn at (100,50), rotated
    --- renderer:restore()
    --- ```
    function transform(self, mat: Mat2D): ()
    --- **Mask all future drawing to only appear inside this shape.**
    ---
    --- Like cutting a hole in paper — after clipPath(), only the area inside
    --- the clip path is visible. Everything outside is hidden.
    --- Lasts until the matching restore().
    ---
    --- ```lua
    --- renderer:save()
    --- renderer:clipPath(circlePath) -- cut a circular window
    --- renderer:drawPath(bigRect, paint) -- only the part inside the circle shows
    --- renderer:restore() -- remove the mask
    --- ```
    function clipPath(self, path: Path): ()
end

--- **Vertex position data for mesh rendering.** Used with `renderer:drawImageMesh()`.
--- Created internally by the Rive runtime — you don't create these yourself.
--- Contains (x, y) positions for each vertex of the mesh.
declare class VertexBuffer
end

--- **Triangle indices for mesh rendering.** Used with `renderer:drawImageMesh()`.
--- Created internally by the Rive runtime — you don't create these yourself.
--- Defines which vertices connect to form triangles.
declare class TriangleBuffer
end

-- =============================================================================
-- HIERARCHY / SCENE
-- =============================================================================

--- **Read-only snapshot of a node** from the Rive editor's scene hierarchy.
---
--- You receive this in PathEffect scripts — it tells you where the node
--- is positioned, how it's rotated and scaled, and lets you access its
--- path geometry or paint settings.
---
--- **Key properties:**
--- - `position`, `x`, `y` — where the node is (local coordinates)
--- - `rotation` — angle in radians (use `math.deg()` to convert to degrees)
--- - `scale`, `scaleX`, `scaleY` — size multiplier (1 = normal)
--- - `worldTransform` — the full transformation matrix in world space
---
--- **Example (inside a PathEffect):**
--- ```lua
--- function update(self, pathData, node)
---     local angle = node.rotation
---     local pos = node.position
---     print("Node at", pos.x, pos.y, "rotated", math.deg(angle), "degrees")
--- end
--- ```
declare class NodeReadData
    --- **Where the node is** relative to its parent. A Vector with x and y.
    position: Vector
    --- **Rotation angle in radians.** Use `math.deg(node.rotation)` for degrees.
    --- 0 = no rotation, `math.pi` = 180 degrees.
    rotation: number
    --- **Size multiplier** relative to parent. `Vector.xy(1, 1)` = normal size.
    scale: Vector
    --- **Full transformation in world space** as a Mat2D matrix.
    --- Combines all parent transforms into one. Use to convert between
    --- local and world coordinates.
    worldTransform: Mat2D
    --- **Horizontal position** relative to parent (shortcut for `position.x`).
    x: number
    --- **Vertical position** relative to parent (shortcut for `position.y`).
    y: number
    --- **Horizontal scale** (shortcut for `scale.x`). 1 = normal, 2 = double width.
    scaleX: number
    --- **Vertical scale** (shortcut for `scale.y`). 1 = normal, 0.5 = half height.
    scaleY: number
    --- **Paint settings** if this node is a shape's fill or stroke. nil for non-paint nodes.
    --- Use to read color, style, thickness etc.
    paint: Paint?
    --- **Get this node's shape geometry** as PathData (for reading commands and measuring).
    --- Returns nil if this node isn't a path-type node (like a rectangle or ellipse).
    function asPath(self): PathData?
    --- **Get this node's paint** if it's a fill or stroke node.
    --- Returns nil if this node isn't a paint-type node.
    function asPaint(self): Paint?
end

--- **A node from the Rive scene** that you can read AND write.
---
--- Get it with `artboard:node("name")`. Then move it, rotate it, scale it —
--- your changes appear on screen immediately.
---
--- **Moving a node:**
--- ```lua
--- local shape = artboard:node("MyShape")
--- shape.x = 100          -- move to x=100
--- shape.y = 200          -- move to y=200
--- shape.rotation = math.rad(45)  -- rotate 45 degrees
--- shape.scaleX = 2       -- stretch horizontally
--- ```
---
--- **Walking the hierarchy:**
--- ```lua
--- local parent = shape.parent
--- for _, child in ipairs(shape.children) do
---     print(child.x, child.y)
--- end
--- ```
declare class NodeData
    --- **Where the node is** relative to its parent (read/write).
    position: Vector
    --- **Rotation angle in radians** (read/write).
    --- Use `math.rad(degrees)` to set: `node.rotation = math.rad(45)`
    rotation: number
    --- **Size multiplier** relative to parent (read/write).
    scale: Vector
    --- **Full transformation in world space.** Read-only — reflects all parent transforms.
    worldTransform: Mat2D
    --- **Horizontal position** relative to parent (read/write). Shortcut for `position.x`.
    x: number
    --- **Vertical position** relative to parent (read/write). Shortcut for `position.y`.
    y: number
    --- **Horizontal scale** (read/write). 1 = normal size, 2 = double width.
    scaleX: number
    --- **Vertical scale** (read/write). 1 = normal size, 0.5 = half height.
    scaleY: number
    --- **Paint settings** if this node is a fill or stroke. nil for non-paint nodes.
    paint: Paint?
    --- **All child nodes** of this node (read-only array).
    --- Use `for _, child in ipairs(node.children) do ... end` to iterate.
    children: { NodeData }
    --- **Parent node** in the hierarchy, or nil if this is a root node.
    parent: NodeData?
    --- **Get path geometry** if this is a path-type node. Returns nil otherwise.
    function asPath(self): PathData?
    --- **Get paint settings** if this is a fill/stroke node. Returns nil otherwise.
    function asPaint(self): Paint?
    --- **Set position from a world-space matrix.** The node figures out the right
    --- local position/rotation/scale relative to its parent.
    --- Use when you know where something should be in world space but the node
    --- is nested inside other transformed nodes.
    --- ```lua
    --- local worldPos = Mat2D.withTranslation(300, 200)
    --- node:decompose(worldPos)  -- node moves to (300, 200) in world space
    --- ```
    function decompose(self, worldTransform: Mat2D): ()
end

-- =============================================================================
-- EVENTS
-- =============================================================================

--- Pointer input event for mouse/touch interaction.
---
--- Received in `pointerDown`, `pointerMove`, `pointerUp`, `pointerExit` callbacks.
--- Call `event:hit()` to consume the event (prevent it from reaching nodes behind).
---
--- **Example:**
--- ```lua
--- function pointerDown(self, event)
---     local pos = event.position  -- local coordinates
---     if isInsideMyArea(pos) then
---         event:hit()  -- consume — nothing behind gets this event
---     end
--- end
--- ```
declare class PointerEvent
    --- Pointer position in local coordinates of the node.
    position: Vector
    --- Pointer identifier (0 for mouse, unique per finger for multitouch).
    id: number
    --- Consume this event. Pass `true` for translucent hit (event still reaches nodes behind).
    --- ```lua
    --- event:hit()      -- opaque: blocks nodes behind
    --- event:hit(true)  -- translucent: nodes behind also receive the event
    --- ```
    function hit(self, isTranslucent: boolean?): ()
end

--- PointerEvent constructor. Used when forwarding events to nested artboards.
declare PointerEvent: {
    --- Create a new PointerEvent. `id` should match the original event ID for proper tracking.
    --- ```lua
    --- -- Forward to child artboard in local coordinates:
    --- local childEvent = PointerEvent.new(event.id, localPos)
    --- childArtboard:pointerDown(childEvent)
    --- ```
    new: (id: number, position: Vector) -> PointerEvent,
}

--- **A function called when a trigger fires.** Used with PropertyTrigger listeners.
--- Receives an optional argument with trigger data.
export type Trigger = (any) -> ()

-- =============================================================================
-- CONTEXT & DATA BINDING
-- =============================================================================

--- **Pattern for adding/removing change callbacks** on a Property.
---
--- Two ways to add a listener:
--- ```lua
--- -- Simple: just a callback function
--- score:addListener(function()
---     print("Score changed to:", score.value)
--- end)
---
--- -- Bound: pass self so the callback can access your script's fields
--- score:addListener(self, function(self)
---     self.display.value = tostring(self.score.value)
--- end)
--- ```
---
--- Remove with the same pattern:
--- ```lua
--- score:removeListener(myCallback)
--- ```
export type Listener<T> =
    (<K>(self: T, obj: K, callback: (K) -> ()) -> ())
    & ((self: T, callback: () -> ()) -> ())

--- **A live value connected to the Rive editor.** Read it, write it, listen for changes.
---
--- Properties are the bridge between your script and the Rive editor's ViewModel.
--- When the editor changes a value, your listener fires. When your script changes
--- `.value`, the editor UI updates automatically.
---
--- **Reading and writing:**
--- ```lua
--- local score = viewModel:getNumber("score")
--- print(score.value)   -- read the current value
--- score.value = 42     -- change it (editor updates immediately)
--- ```
---
--- **Reacting to changes (listeners):**
--- ```lua
--- score:addListener(function()
---     print("Score is now:", score.value)
--- end)
--- ```
export type Property<T> = {
    --- **The current value.** Read it to get the value, write it to change it.
    --- Changes are immediately visible in the Rive editor.
    value: T,
    --- **Get notified when this value changes.** Your callback runs every time
    --- the value is updated — whether by your script or by the editor.
    addListener: Listener<Property<T>>,
    --- **Stop listening** for changes. Pass the same callback you gave to addListener.
    removeListener: Listener<Property<T>>,
}

--- **A number property** from the ViewModel. Read/write via `.value`.
--- ```lua
--- local speed = vm:getNumber("speed")
--- speed.value = 5.0  -- set it
--- print(speed.value)  -- read it
--- ```
export type PropertyNumber = Property<number>

--- **A text property** from the ViewModel. Read/write via `.value`.
--- ```lua
--- local name = vm:getString("playerName")
--- name.value = "Player 1"
--- ```
export type PropertyString = Property<string>

--- **A true/false property** from the ViewModel. Read/write via `.value`.
--- ```lua
--- local active = vm:getBoolean("isActive")
--- if active.value then print("It's on!") end
--- ```
export type PropertyBoolean = Property<boolean>

--- **A color property** from the ViewModel. Read/write via `.value`.
--- ```lua
--- local tint = vm:getColor("tintColor")
--- tint.value = Color.rgb(255, 0, 0)  -- change to red
--- ```
export type PropertyColor = Property<Color>

--- Trigger property. Call fire() to trigger, addListener() to react.
---
--- **Example:**
--- ```lua
--- local btn = viewModel:getTrigger("onButtonPress")
--- btn:addListener(function()
---     print("Button pressed!")
--- end)
--- -- To fire programmatically:
--- btn:fire()
--- ```
export type PropertyTrigger = {
    fire: (self: PropertyTrigger) -> (),
    addListener: Listener<PropertyTrigger>,
    removeListener: Listener<PropertyTrigger>,
}

--- **Array of valid enum option strings.** Get from `enumProperty:values()`.
--- Use `#options` for count, `options[1]` through `options[#options]` for values.
--- ```lua
--- local options = theme:values()
--- for i = 1, #options do print(i, options[i]) end
--- ```
export type EnumValues = {
    [number]: string,
}

--- Property holding an enum string value. Call values() to get all valid options.
---
--- **Example:**
--- ```lua
--- local theme = viewModel:getEnum("theme")
--- local options = theme:values()
--- for i = 1, #options do print(options[i]) end
--- theme.value = options[1]  -- set to first option
--- ```
export type PropertyEnum = Property<string> & {
    values: (self: PropertyEnum) -> EnumValues,
}

--- ViewModel data binding interface. Connect to editor-defined properties by name.
---
--- Get properties with type-specific getters. Each returns nil if the property
--- doesn't exist on this ViewModel.
---
--- **Example:**
--- ```lua
--- function init(self, context)
---     local vm = context:viewModel()
---     if vm then
---         self.score = vm:getNumber("score")
---         self.name = vm:getString("playerName")
---         self.active = vm:getBoolean("isActive")
---         self.tint = vm:getColor("tintColor")
---         self.items = vm:getList("inventory")
---     end
---     return true
--- end
--- ```
declare class ViewModel
    --- Name of this ViewModel definition (read-only).
    name: string
    --- Get a number property by name. Returns nil if not found.
    --- ```lua
    --- local speed = vm:getNumber("speed")
    --- if speed then print(speed.value) end
    --- ```
    function getNumber(self, name: string): PropertyNumber?
    --- Get a string property by name. Returns nil if not found.
    function getString(self, name: string): PropertyString?
    --- Get a boolean property by name. Returns nil if not found.
    function getBoolean(self, name: string): PropertyBoolean?
    --- Get a color property by name. Returns nil if not found.
    function getColor(self, name: string): PropertyColor?
    --- Get a trigger property by name. Returns nil if not found.
    --- ```lua
    --- local btn = vm:getTrigger("onClick")
    --- btn:addListener(function() print("Clicked!") end)
    --- ```
    function getTrigger(self, name: string): PropertyTrigger?
    --- Get a list property (array of ViewModels) by name. Returns nil if not found.
    --- ```lua
    --- local list = vm:getList("items")
    --- if list then
    ---     for i = 1, list.length do ... end
    --- end
    --- ```
    function getList(self, name: string): PropertyList?
    --- Get a nested ViewModel property by name. Returns nil if not found.
    function getViewModel(self, name: string): PropertyViewModel?
    --- Get an enum property by name. Returns nil if not found.
    function getEnum(self, name: string): PropertyEnum?
    --- Create an independent copy of this ViewModel. Changes to the copy
    --- won't affect the original. Useful for list items.
    function instance(self): ViewModel
end

--- **A dynamic list of ViewModel items** — like an array you can add to, remove from, and reorder.
---
--- Get from `vm:getList("name")`. Each item in the list is a ViewModel with its own properties.
--- Think of it like a to-do list, inventory, or any repeating collection.
---
--- **Adding items:**
--- ```lua
--- local list = vm:getList("items")
--- local template = vm:getViewModel("itemTemplate")
--- local newItem = template.value:instance()  -- create a copy
--- list:push(newItem)  -- add to the end
--- ```
---
--- **Reading items:**
--- ```lua
--- for i = 1, list.length do
---     local item = list[i]  -- access by index
---     print(item:getString("name").value)
--- end
--- ```
---
--- **Removing items:**
--- ```lua
--- list:pop()    -- remove last item
--- list:shift()  -- remove first item
--- ```
export type PropertyList = {
    --- **How many items** are in the list. Same as `count`.
    length: number,
    --- **How many items** are in the list. Same as `length`.
    count: number,
    --- **Access items by index.** `list[1]` is the first item. Index starts at 1 (Luau style).
    [number]: ViewModel,
    --- **Get an item by index.** Returns nil if index is out of range.
    --- Same as `list[index]` but returns nil instead of erroring on bad index.
    item: (self: PropertyList, index: number) -> ViewModel?,
    --- **Add an item to the end** of the list.
    push: (self: PropertyList, vm: ViewModel) -> (),
    --- **Insert an item at a specific position.** Existing items shift forward.
    insert: (self: PropertyList, vm: ViewModel, index: number) -> (),
    --- **Swap two items' positions** in the list. Useful for reordering.
    swap: (self: PropertyList, index1: number, index2: number) -> (),
    --- **Remove and return the last item.** Returns nil if the list is empty.
    pop: (self: PropertyList) -> ViewModel?,
    --- **Remove and return the first item.** Remaining items shift back.
    shift: (self: PropertyList) -> ViewModel?,
    --- **Get notified when items are added, removed, or reordered.**
    addListener: Listener<PropertyList>,
    --- **Stop listening** for list changes.
    removeListener: Listener<PropertyList>,
}

--- **A reference to a nested ViewModel** inside another ViewModel.
--- Access the actual ViewModel through `.value`.
--- ```lua
--- local nested = vm:getViewModel("playerStats")
--- local hp = nested.value:getNumber("health")
--- print(hp.value)
--- ```
export type PropertyViewModel = {
    --- **The nested ViewModel.** Use this to access its properties.
    value: ViewModel,
}

--- **Navigate up the ViewModel hierarchy.** Useful when a script is on a
--- nested artboard but needs to access data from a parent artboard.
---
--- ```lua
--- local dc = context:dataContext()
--- -- Walk up to find the parent's ViewModel:
--- local parentDC = dc:parent()
--- if parentDC then
---     local parentVM = parentDC:viewModel()
--- end
--- ```
declare class DataContext
    --- **Go up one level** in the ViewModel hierarchy.
    --- Returns nil if you're already at the root (top level).
    function parent(self): DataContext?
    --- **Get the ViewModel at this level.** Returns nil if no ViewModel is bound here.
    function viewModel(self): ViewModel?
end

--- Runtime context passed to `init()`. Your bridge to the Rive editor.
---
--- Provides access to:
--- - **ViewModels** — data binding to editor properties
--- - **Assets** — images, blobs, audio files embedded in the .riv
--- - **Updates** — request re-evaluation with markNeedsUpdate()
---
--- **Example:**
--- ```lua
--- function init(self, context)
---     self.context = context
---     self.vm = context:viewModel()
---     self.logo = context:image("logo")
---     self.sound = context:audio("click")
---     return true  -- return false to disable this script
--- end
--- ```
declare class Context
    --- Get the ViewModel bound to the artboard this script is on.
    --- Returns nil if no ViewModel is bound.
    function viewModel(self): ViewModel?
    --- Get the root ViewModel of the entire file. Useful for global settings.
    function rootViewModel(self): ViewModel?
    --- Get the DataContext for hierarchy traversal.
    function dataContext(self): DataContext?
    --- Load an image asset by name. Returns nil if not found.
    --- ```lua
    --- local img = context:image("background")
    --- ```
    function image(self, name: string): Image?
    --- Load a blob (binary data) asset by name. Returns nil if not found.
    function blob(self, name: string): Blob?
    --- Load an audio asset by name. Returns nil if not found.
    --- ```lua
    --- local snd = context:audio("click")
    --- Audio.play(snd)
    --- ```
    function audio(self, name: string): AudioSource?
    --- Request that the runtime re-evaluate this script on the next frame.
    --- Call this when you change data that requires visual updates outside of advance().
    function markNeedsUpdate(self): ()
end

-- =============================================================================
-- ASSETS
-- =============================================================================

--- Image asset loaded from the .riv file. Obtain via `context:image(name)`.
---
--- Draw with `renderer:drawImage()` or `renderer:drawImageMesh()`.
---
--- **Example:**
--- ```lua
--- local img = context:image("logo")
--- local sampler = ImageSampler("clamp", "clamp", "bilinear")
--- renderer:drawImage(img, sampler, "srcOver", 1.0)
--- ```
declare class Image
    --- Width of the image in pixels.
    width: number
    --- Height of the image in pixels.
    height: number
end

--- **What happens when sampling outside the image bounds.**
---
--- - `"clamp"` — Stretches the edge pixels outward (most common).
--- - `"repeat"` — Tiles the image infinitely, like a pattern.
--- - `"mirror"` — Tiles the image but flips every other copy.
export type ImageWrap = "clamp" | "repeat" | "mirror"

--- **Image quality setting** — smooth or pixelated.
---
--- - `"bilinear"` — Smooth blending between pixels (best for photos and gradients).
--- - `"nearest"` — No blending, sharp pixels visible (best for pixel art).
export type ImageFilter = "bilinear" | "nearest"

--- Controls how images are sampled: wrapping behavior and filter quality.
---
--- **Example:**
--- ```lua
--- -- Smooth clamped sampling (most common):
--- local sampler = ImageSampler("clamp", "clamp", "bilinear")
--- -- Pixel-art tiling:
--- local tiled = ImageSampler("repeat", "repeat", "nearest")
--- ```
declare class ImageSampler
end

--- **Create an ImageSampler** — controls image quality and tiling behavior.
---
--- ```lua
--- -- Most common: smooth, no tiling
--- local sampler = ImageSampler("clamp", "clamp", "bilinear")
---
--- -- Pixel art: sharp edges, tiled
--- local tiled = ImageSampler("repeat", "repeat", "nearest")
--- ```
declare ImageSampler: ((wrapX: ImageWrap, wrapY: ImageWrap, filter: ImageFilter) -> ImageSampler) & {
    --- **Create an ImageSampler** with wrapping and filtering settings.
    --- - `wrapX` / `wrapY` — What happens at edges: `"clamp"`, `"repeat"`, or `"mirror"`
    --- - `filter` — Quality: `"bilinear"` (smooth) or `"nearest"` (pixelated)
    new: (wrapX: ImageWrap, wrapY: ImageWrap, filter: ImageFilter) -> ImageSampler,
}

--- Binary data asset (fonts, JSON, custom data). Obtain via `context:blob(name)`.
---
--- **Example:**
--- ```lua
--- local b = context:blob("config")
--- if b then
---     print(b.name, b.size, "bytes")
---     -- b.data is a Luau buffer
--- end
--- ```
declare class Blob
    --- Asset name.
    name: string
    --- Size in bytes.
    size: number
    --- Raw binary data as a Luau buffer.
    data: buffer
end

--- **A sound file embedded in your .riv.** Load it with `context:audio("name")`,
--- then play it with `Audio.play(source)`.
---
--- AudioSource is just a reference to the audio data — it doesn't play by itself.
--- Think of it as a CD: you need a player (`Audio.play`) to hear it.
---
--- ```lua
--- function init(self, context)
---     self.clickSound = context:audio("click")
---     return true
--- end
---
--- function pointerDown(self, event)
---     event:hit()
---     Audio.play(self.clickSound)  -- play the sound!
--- end
--- ```
declare class AudioSource
end

--- Playing audio instance. Control playback with stop(), seek(), volume.
---
--- **Example:**
--- ```lua
--- local sound = Audio.play(source)
--- sound.volume = 0.5
--- -- Later:
--- if sound:completed() then print("Done!") end
--- ```
declare class AudioSound
    --- Playback volume (0.0 = silent, 1.0 = full volume). Read/write.
    volume: number
    --- Stop playback. Optional fade-out time in seconds.
    --- ```lua
    --- sound:stop(0.5)  -- fade out over 0.5 seconds
    --- ```
    function stop(self, fadeToStopTime: number?): ()
    --- Jump to a specific time in seconds.
    function seek(self, seconds: number): ()
    --- Jump to a specific sample frame.
    function seekFrame(self, frame: number): ()
    --- Returns true if playback has finished.
    function completed(self): boolean
    --- Current playback position in seconds.
    function time(self): number
    --- Current playback position in sample frames.
    function timeFrame(self): number
end

-- =============================================================================
-- SCENE
-- =============================================================================

--- Timeline animation from the Rive editor. Get via `artboard:animation(name)`.
---
--- **Example:**
--- ```lua
--- local anim = artboard:animation("idle")
--- function advance(self, seconds)
---     anim:advance(seconds)  -- returns false when non-looping anim ends
---     return true
--- end
--- ```
declare class Animation
    --- Total duration of the animation in seconds.
    duration: number
    --- Advance the animation by `deltaTime` seconds.
    --- Returns false when a non-looping animation reaches the end.
    function advance(self, deltaTime: number): boolean
    --- Jump to a specific time in seconds.
    function setTime(self, seconds: number): ()
    --- Jump to a specific frame number.
    function setTimeFrames(self, frames: number): ()
    --- Jump to a percentage of the animation (0.0 = start, 1.0 = end).
    function setTimePercentage(self, percent: number): ()
    --- Start playing the animation.
    function play(self): ()
end

--- Rive artboard instance. The root container for all Rive content.
---
--- **Drawing:** Call `advance(dt)` then `draw(renderer)` each frame.
--- **Hierarchy:** Access nodes by name with `node(name)`.
--- **Pointer events:** Forward events for interactive state machines.
---
--- **Example:**
--- ```lua
--- function init(self, context)
---     self.child = context:artboard("NestedArtboard")
---     return true
--- end
---
--- function advance(self, seconds)
---     self.child:advance(seconds)
---     return true
--- end
---
--- function draw(self, renderer)
---     self.child:draw(renderer)
--- end
--- ```
declare class Artboard
    --- Artboard width in pixels (read/write).
    width: number
    --- Artboard height in pixels (read/write).
    height: number
    --- Whether the frame origin is used for rendering.
    frameOrigin: boolean
    --- Associated ViewModel data (typed). Read-only.
    data: any
    --- Draw the artboard's current state to the renderer.
    function draw(self, renderer: Renderer): ()
    --- Advance all animations and state machines by `deltaTime` seconds.
    --- Returns false when a non-looping animation completes.
    function advance(self, deltaTime: number): boolean
    --- Create an independent copy of this artboard, optionally with a different ViewModel.
    --- ```lua
    --- local copy = artboard:instance()
    --- ```
    function instance(self, viewModel: ViewModel?): Artboard
    --- Get a named animation. Returns nil if not found.
    --- ```lua
    --- local anim = artboard:animation("bounce")
    --- ```
    function animation(self, name: string): Animation?
    --- Get the bounding box as (min, max) Vectors.
    --- ```lua
    --- local min, max = artboard:bounds()
    --- local width = max.x - min.x
    --- ```
    function bounds(self): (Vector, Vector)
    --- Get a named node for reading/writing properties. Returns nil if not found.
    --- ```lua
    --- local shape = artboard:node("MyShape")
    --- shape.x = 100
    --- ```
    function node(self, name: string): NodeData?
    --- Add this artboard's outline to a path, optionally transformed.
    function addToPath(self, path: Path, transform: Mat2D?): ()
    --- Handle a pointer-down event. Returns hit count (0 = no hit).
    function pointerDown(self, event: PointerEvent): number
    --- Handle a pointer-up event. Returns hit count (0 = no hit).
    function pointerUp(self, event: PointerEvent): number
    --- Handle a pointer-move event. Returns hit count (0 = no hit).
    function pointerMove(self, event: PointerEvent): number
    --- Handle a pointer-exit event. Returns hit count (0 = no hit).
    function pointerExit(self, event: PointerEvent): number
end

-- =============================================================================
-- AUDIO SYSTEM
-- =============================================================================

--- Global audio playback system. Play sounds, schedule playback, query timing.
---
--- **Example:**
--- ```lua
--- function init(self, context)
---     self.clickSound = context:audio("click")
---     return true
--- end
---
--- function pointerDown(self, event)
---     event:hit()
---     Audio.play(self.clickSound)
--- end
--- ```
declare Audio: {
    --- Current audio system time in seconds.
    time: () -> number,
    --- Audio sample rate (e.g. 44100, 48000).
    sampleRate: () -> number,
    --- Current audio system time in sample frames.
    timeFrame: () -> number,
    --- Play a sound immediately. Returns the AudioSound for volume/seek control.
    --- ```lua
    --- local sound = Audio.play(source)
    --- sound.volume = 0.5
    --- ```
    play: (source: AudioSource) -> AudioSound?,
    --- Play a sound at an absolute audio time (seconds).
    playAtTime: (source: AudioSource, time: number) -> AudioSound?,
    --- Play a sound after a delay (seconds from now).
    playInTime: (source: AudioSource, delay: number) -> AudioSound?,
    --- Play a sound at an absolute frame number.
    playAtFrame: (source: AudioSource, frame: number) -> AudioSound?,
    --- Play a sound after a delay in frames.
    playInFrame: (source: AudioSource, frames: number) -> AudioSound?,
}

-- =============================================================================
-- DATA VALUES (for Converters)
-- =============================================================================

--- **A value that can hold different types** — used in Converter scripts.
---
--- When you write a Converter, the input arrives as a DataValue. Since it could
--- be a number, string, boolean, or color, you check which type it is first:
---
--- ```lua
--- function convert(self, input)
---     if input:isNumber() then
---         return input.value * 2       -- it's a number, double it
---     elseif input:isString() then
---         return string.upper(input.value)  -- it's text, capitalize it
---     end
--- end
--- ```
declare class DataValue
    --- **Is this a number?** Returns true if `.value` is a number type.
    function isNumber(self): boolean
    --- **Is this a string?** Returns true if `.value` is a text type.
    function isString(self): boolean
    --- **Is this a boolean?** Returns true if `.value` is true/false.
    function isBoolean(self): boolean
    --- **Is this a color?** Returns true if `.value` is a Color.
    function isColor(self): boolean
end

--- **A DataValue holding a number.** Read or write via `.value`.
---
--- ```lua
--- local dv = DataValue.number()
--- dv.value = 42
--- print(dv.value)  -- 42
--- ```
declare class DataValueNumber
    --- **The number** stored in this DataValue (read/write).
    value: number
    --- Returns true (this IS a number DataValue).
    function isNumber(self): boolean
    --- Returns false (this is not a string).
    function isString(self): boolean
    --- Returns false (this is not a boolean).
    function isBoolean(self): boolean
    --- Returns false (this is not a color).
    function isColor(self): boolean
end

--- **A DataValue holding a string (text).** Read or write via `.value`.
---
--- ```lua
--- local dv = DataValue.string()
--- dv.value = "Hello"
--- ```
declare class DataValueString
    --- **The text** stored in this DataValue (read/write).
    value: string
    --- Returns false (this is not a number).
    function isNumber(self): boolean
    --- Returns true (this IS a string DataValue).
    function isString(self): boolean
    --- Returns false (this is not a boolean).
    function isBoolean(self): boolean
    --- Returns false (this is not a color).
    function isColor(self): boolean
end

--- **A DataValue holding a boolean (true/false).** Read or write via `.value`.
---
--- ```lua
--- local dv = DataValue.boolean()
--- dv.value = true
--- ```
declare class DataValueBoolean
    --- **The true/false value** stored in this DataValue (read/write).
    value: boolean
    --- Returns false (this is not a number).
    function isNumber(self): boolean
    --- Returns false (this is not a string).
    function isString(self): boolean
    --- Returns true (this IS a boolean DataValue).
    function isBoolean(self): boolean
    --- Returns false (this is not a color).
    function isColor(self): boolean
end

--- **A DataValue holding a Color.** Access the full color or individual channels.
---
--- ```lua
--- local dv = DataValue.color()
--- dv.value = Color.rgb(255, 0, 0)  -- set to red
--- dv.red = 128                      -- change just the red channel
--- print(dv.alpha)                   -- read the alpha channel
--- ```
declare class DataValueColor
    --- **The full Color** stored in this DataValue (read/write).
    value: Color
    --- **Red channel** (0-255, read/write). 0 = no red, 255 = full red.
    red: number
    --- **Green channel** (0-255, read/write). 0 = no green, 255 = full green.
    green: number
    --- **Blue channel** (0-255, read/write). 0 = no blue, 255 = full blue.
    blue: number
    --- **Alpha (transparency) channel** (0-255, read/write). 0 = invisible, 255 = solid.
    alpha: number
    --- Returns false (this is not a number).
    function isNumber(self): boolean
    --- Returns false (this is not a string).
    function isString(self): boolean
    --- Returns false (this is not a boolean).
    function isBoolean(self): boolean
    --- Returns true (this IS a color DataValue).
    function isColor(self): boolean
end

--- **Create typed DataValues** for use in Converter scripts.
---
--- ```lua
--- local numVal = DataValue.number()   -- holds a number (starts at 0)
--- local strVal = DataValue.string()   -- holds text (starts at "")
--- local boolVal = DataValue.boolean() -- holds true/false (starts at false)
--- local colVal = DataValue.color()    -- holds a Color
--- ```
declare DataValue: {
    --- **Create a number DataValue** (starts at 0).
    number: () -> DataValueNumber,
    --- **Create a string DataValue** (starts at "").
    string: () -> DataValueString,
    --- **Create a boolean DataValue** (starts at false).
    boolean: () -> DataValueBoolean,
    --- **Create a color DataValue.**
    color: () -> DataValueColor,
}

-- =============================================================================
-- SCRIPT FRAMEWORK — Protocol Types
-- =============================================================================

-- These generic types define the script protocols available in Rive.
-- Each protocol specifies lifecycle methods that the Rive runtime calls.
-- Your script returns a factory function that creates instances of these protocols.

--- **A value controlled by the Rive editor** that your script can READ but not write.
---
--- Inputs are bound in the Rive editor UI — you drag a property to your script's input.
--- At runtime, the value appears directly on `self` (no `.value` needed).
---
--- **Supported types:** `Input<number>`, `Input<boolean>`, `Input<string>`, `Input<Color>`
---
--- **Example:**
--- ```lua
--- type MyNode = {
---     speed: Input<number>,    -- bound in Rive editor
---     label: Input<string>,    -- bound in Rive editor
--- }
---
--- function advance(self: MyNode, seconds: number): boolean
---     local s = self.speed     -- read the value directly (NOT .value)
---     print("Speed is:", s)
---     return true
--- end
--- ```
export type Input<T> = T

--- **A value your script provides** that the Rive runtime reads each frame.
---
--- Outputs are the opposite of Inputs: your script WRITES them, and the editor/runtime
--- reads them. Use outputs to send computed results back to the editor (e.g., for
--- data binding to other nodes).
---
--- **Example:**
--- ```lua
--- type MyNode = {
---     result: Output<number>,  -- the runtime reads this each frame
--- }
---
--- function advance(self: MyNode, seconds: number): boolean
---     self.result = math.sin(seconds) * 100  -- write directly (NOT .value)
---     return true
--- end
--- ```
export type Output<T> = T

--- Node script protocol — the most common script type.
---
--- **Lifecycle:** `init` → `update` → `advance` → `draw` (each frame)
---
--- **Required:** At minimum, implement `draw` to render content.
---
--- **Lifecycle methods:**
--- - `init(self, context)` — called once on creation. Return false to disable.
--- - `update(self)` — called when inputs change.
--- - `advance(self, seconds)` — called every frame with delta time. Return true to keep running.
--- - `draw(self, renderer)` — called every frame to render. Keep pure (no state changes)!
---
--- **Pointer methods (optional):**
--- - `pointerDown(self, event)`, `pointerMove(self, event)`
--- - `pointerUp(self, event)`, `pointerExit(self, event)`
---
--- **Example:**
--- ```lua
--- type MyCircle = {
---     radius: Input<number>,
---     path: Path,
---     paint: Paint,
---     context: Context,
--- }
---
--- function init(self: MyCircle, context: Context): boolean
---     self.context = context
---     self.path = Path.new()
---     self.paint = Paint.with({ color = Color.rgb(255, 0, 0) })
---     return true
--- end
---
--- function draw(self: MyCircle, renderer: Renderer)
---     renderer:drawPath(self.path, self.paint)
--- end
---
--- return function(): Node<MyCircle>
---     return { init = init, draw = draw, context = late() }
--- end
--- ```
export type Node<T> = T & {
    init: ((self: T, context: Context) -> boolean)?,
    update: ((self: T) -> ())?,
    advance: ((self: T, seconds: number) -> boolean)?,
    draw: ((self: T, renderer: Renderer) -> ())?,
    pointerDown: ((self: T, event: PointerEvent) -> ())?,
    pointerMove: ((self: T, event: PointerEvent) -> ())?,
    pointerUp: ((self: T, event: PointerEvent) -> ())?,
    pointerExit: ((self: T, event: PointerEvent) -> ())?,
}

--- Layout script — extends Node with size measurement and resize handling.
---
--- Use when your script needs to participate in Rive's layout system (e.g., custom widgets).
---
--- **Additional methods:**
--- - `measure(self)` — return ideal size (Vector) for "Hug" fit type
--- - `resize(self, size)` — called when the layout size changes
---
--- **Example:**
--- ```lua
--- return function(): Layout<MyWidget>
---     return { init = init, draw = draw, resize = resize, measure = measure }
--- end
--- ```
export type Layout<T> = Node<T> & {
    measure: ((self: T) -> Vector)?,
    resize: (self: T, size: Vector) -> (),
}

--- Converter script — transforms data between ViewModel bindings.
---
--- Use when you need to convert between types in data bindings
--- (e.g., number → string, percentage → color, etc.).
---
--- **Required methods:**
--- - `convert(self, input: I) -> O` — forward conversion
--- - `reverseConvert(self, output: O) -> I` — reverse conversion
---
--- **Example:**
--- ```lua
--- type TempConverter = {}
---
--- function convert(self: TempConverter, celsius: number): string
---     return string.format("%.1f°F", celsius * 9/5 + 32)
--- end
---
--- function reverseConvert(self: TempConverter, fahrenheit: string): number
---     return (tonumber(fahrenheit) - 32) * 5/9
--- end
---
--- return function(): Converter<TempConverter, number, string>
---     return { convert = convert, reverseConvert = reverseConvert }
--- end
--- ```
export type Converter<T, I, O> = T & {
    init: ((self: T, context: Context) -> boolean)?,
    convert: (self: T, input: I) -> O,
    reverseConvert: (self: T, input: O) -> I,
    advance: ((self: T, seconds: number) -> boolean)?,
}

--- Path effect script — modifies path geometry in real-time.
---
--- Receives the original path data and node transform, returns modified geometry.
--- Use for procedural effects like dashes, waves, distortion, etc.
---
--- **Required:** `update(self, pathData, node)` — must return PathData or a new Path.
---
--- **Example:**
--- ```lua
--- type WaveEffect = {
---     time: number,
---     context: Context,
--- }
---
--- function update(self: WaveEffect, pathData: PathData, node: NodeReadData): Path
---     local out = Path.new()
---     local m = pathData:measure()
---     for d = 0, m.length, 2 do
---         local offset = math.sin(d * 0.1 + self.time) * 10
---         local p = m:warp(Vector.xy(d, offset))
---         if d == 0 then out:moveTo(p) else out:lineTo(p) end
---     end
---     return out
--- end
---
--- return function(): PathEffect<WaveEffect>
---     return { update = update, advance = advance, context = late() }
--- end
--- ```
export type PathEffect<T> = T & {
    init: ((self: T, context: Context) -> boolean)?,
    update: (self: T, pathData: PathData, node: NodeReadData) -> (PathData | Path),
    advance: ((self: T, seconds: number) -> boolean)?,
}

--- Listener action script — responds to state machine listener events.
---
--- **Required:** `perform(self, pointerEvent)` — called when a state machine listener fires.
---
--- **Example:**
--- ```lua
--- type ClickAction = { context: Context }
---
--- function perform(self: ClickAction, event: PointerEvent)
---     print("Listener fired at:", event.position.x, event.position.y)
--- end
---
--- return function(): ListenerAction<ClickAction>
---     return { perform = perform, context = late() }
--- end
--- ```
export type ListenerAction<T> = T & {
    init: ((self: T, context: Context) -> boolean)?,
    perform: (self: T, pointerEvent: PointerEvent) -> (),
}

--- Transition condition script — custom logic for state machine transitions.
---
--- **Required:** `evaluate(self)` — return true to allow the transition, false to block it.
--- Called every frame while the transition is being considered.
---
--- **Example:**
--- ```lua
--- type ScoreCheck = {
---     score: Property<number>?,
---     threshold: Input<number>,
--- }
---
--- function evaluate(self: ScoreCheck): boolean
---     return self.score and self.score.value >= self.threshold
--- end
---
--- return function(): TransitionCondition<ScoreCheck>
---     return { init = init, evaluate = evaluate, context = late() }
--- end
--- ```
export type TransitionCondition<T> = T & {
    init: ((self: T, context: Context) -> boolean)?,
    evaluate: (self: T) -> boolean,
}

-- =============================================================================
-- TESTING FRAMEWORK
-- =============================================================================

--- **Test assertion object.** Use `expect(value)` to create one, then chain with
--- a matcher to check if the value meets your expectation.
---
--- ```lua
--- expect(2 + 2).is(4)              -- passes: 4 equals 4
--- expect(score).greaterThan(0)      -- passes if score > 0
--- expect(name).never.is(nil)        -- passes if name is NOT nil
--- ```
export type Expectation = {
    --- **Check equality.** Passes if the value equals `expected`.
    --- ```lua
    --- expect(result).is(42)
    --- expect(color).is(Color.rgb(255, 0, 0))
    --- ```
    is: (self: Expectation, expected: any) -> (),
    --- **Check greater than.** Passes if value > `n`.
    greaterThan: (self: Expectation, n: number) -> (),
    --- **Check greater than or equal.** Passes if value >= `n`.
    greaterThanOrEqual: (self: Expectation, n: number) -> (),
    --- **Check less than.** Passes if value < `n`.
    lessThan: (self: Expectation, n: number) -> (),
    --- **Check less than or equal.** Passes if value <= `n`.
    lessThanOrEqual: (self: Expectation, n: number) -> (),
    --- **Flip the check.** Makes any following matcher check the OPPOSITE.
    --- ```lua
    --- expect(value).never.is(nil)        -- passes if value is NOT nil
    --- expect(score).never.lessThan(0)    -- passes if score >= 0
    --- ```
    never: Expectation,
}

--- **Test runner** — use to organize tests into groups and individual cases.
---
--- Received in the `setup()` function of Test scripts.
---
--- ```lua
--- function setup(test)
---     test:group("Math helpers", function()
---         test:case("clamp works", function()
---             expect(math.clamp(5, 0, 10)).is(5)
---             expect(math.clamp(-1, 0, 10)).is(0)
---         end)
---     end)
--- end
--- ```
export type Tester = {
    --- **Create a test group** — a named category that contains test cases.
    --- Groups help organize related tests together.
    group: (self: Tester, name: string, fn: () -> ()) -> (),
    --- **Define a single test** with a name and a function containing expectations.
    --- If any `expect(...)` call inside fails, the test fails.
    case: (self: Tester, name: string, fn: () -> ()) -> (),
}

-- =============================================================================
-- GLOBAL FUNCTIONS
-- =============================================================================

--- Deferred initialization marker. Use in factory return tables for fields
--- that will be assigned later (e.g., in `init()`).
---
--- **Why:** Luau's type checker needs to see all fields at construction time.
--- `late()` tells it "this field exists but will be set up during init()."
---
--- **Example:**
--- ```lua
--- return function(): Node<MyNode>
---     return {
---         init = init,
---         draw = draw,
---         context = late(),   -- assigned in init()
---         path = late(),      -- assigned in init()
---     }
--- end
--- ```
declare function late(): any

--- Create an expectation for testing. Use in Test scripts inside test.case().
--- ```lua
--- expect(2 + 2).is(4)
--- expect(value).greaterThan(0)
--- expect(result).never.is(nil)
--- ```
declare function expect(value: any): Expectation
