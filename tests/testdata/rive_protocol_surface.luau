--!strict
-- Positive acceptance fixture for the complete Rive script-protocol surface.

type NodeState = {}

local function initNode(_self: NodeState, _context: Context): boolean
    return true
end

local function updateNode(_self: NodeState) end

local function advanceNode(_self: NodeState, seconds: number): boolean
    return seconds >= 0
end

local function drawNode(_self: NodeState, renderer: Renderer)
    renderer:save()
    renderer:restore()
end

local nodeProtocol: Node<NodeState> = {
    init = initNode,
    update = updateNode,
    advance = advanceNode,
    draw = drawNode,
}

type LayoutState = {}

local function measureLayout(_self: LayoutState): Vector
    return Vector.xy(100, 100)
end

local function resizeLayout(
    _self: LayoutState,
    _size: Vector,
    _displayScale: number
)
end

local layoutProtocol: Layout<LayoutState> = {
    measure = measureLayout,
    resize = resizeLayout,
}

type ConverterState = {}

local function convert(
    _self: ConverterState,
    input: DataValue
): DataValue
    return input
end

local function reverseConvert(
    _self: ConverterState,
    input: DataValue
): DataValue
    return input
end

local converterProtocol: Converter<ConverterState, DataValue, DataValue> = {
    convert = convert,
    reverseConvert = reverseConvert,
}

type PathEffectState = {}

local function updatePath(
    _self: PathEffectState,
    path: PathData,
    _node: NodeReadData
): PathData
    return path
end

local pathEffectProtocol: PathEffect<PathEffectState> = {
    update = updatePath,
}

type ListenerState = {}

local function performAction(
    _self: ListenerState,
    _context: ListenerContext
)
end

local function performLegacy(_self: ListenerState, _event: PointerEvent) end

local listenerProtocol: ListenerAction<ListenerState> = {
    performAction = performAction,
    perform = performLegacy,
}

type TransitionState = {}

local function evaluate(_self: TransitionState): boolean
    return true
end

local transitionProtocol: TransitionCondition<TransitionState> = {
    evaluate = evaluate,
}

type InterpolatorState = {}

local function transform(_self: InterpolatorState, factor: number): number
    return factor
end

local function transformValue(
    _self: InterpolatorState,
    valueFrom: number,
    valueTo: number,
    factor: number
): number
    return valueFrom + (valueTo - valueFrom) * factor
end

local interpolatorProtocol: Interpolator<InterpolatorState> = {
    transform = transform,
    transformValue = transformValue,
}

-- Runtime 344 provides identity/linear fallback behavior for omitted methods.
local fallbackInterpolatorProtocol: Interpolator<InterpolatorState> = {}

return function(): Node<NodeState>
    print(
        layoutProtocol,
        converterProtocol,
        pathEffectProtocol,
        listenerProtocol,
        transitionProtocol,
        interpolatorProtocol,
        fallbackInterpolatorProtocol
    )
    return nodeProtocol
end
