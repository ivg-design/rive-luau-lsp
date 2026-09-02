--!strict
-- Positive acceptance fixture for the runtime-v0.1.344 Layout resize surface.

type ScaledLayout = {}

local function resizeWithDisplayScale(
    _self: ScaledLayout,
    size: Vector,
    displayScale: number
)
    print(size.x, size.y, displayScale)
end

local scaledLayout: Layout<ScaledLayout> = {
    resize = resizeWithDisplayScale,
}

type LegacyLayout = {}

local function resizeWithoutDisplayScale(_self: LegacyLayout, size: Vector)
    print(size.x, size.y)
end

-- Runtime 344 passes a third argument, but ordinary Luau callbacks that
-- declare only self and size ignore it. Keep that source compatibility typed.
local legacyLayout: Layout<LegacyLayout> = {
    resize = resizeWithoutDisplayScale,
}

return function(): Layout<ScaledLayout>
    print(legacyLayout)
    return scaledLayout
end
