-- Positive acceptance fixture for callable surface confirmed in the exact
-- accepted runtime-v0.1.316 wrappers plus the current stable Editor reference.

local function _checkRuntime316(
    context: Context,
    blob: Blob,
    viewModel: ViewModel,
    list: PropertyList,
    pointer: PointerEvent,
    audio: AudioSource,
    vertices: VertexBuffer,
    triangles: TriangleBuffer,
    command: PathCommand,
    pathData: PathData,
    enumValues: EnumValues,
    artboard: Artboard<ViewModel?>,
    connected: GamepadConnected,
    changed: GamepadEvent,
    disconnected: GamepadDisconnected,
    shader: Shader,
    canvas: Canvas,
    gpuCanvas: GPUCanvas
)
    context.log("runtime-v0.1.316 surface")
    print(pointer.previousPosition, pointer.timeStamp, audio.duration)
    if blob.data then
        print(buffer.len(blob.data))
    end
    local defaultInstance = viewModel:instance()
    local namedInstance = viewModel:instance("Template")
    print(defaultInstance, namedInstance, list.length, list[1])

    vertices:add(Vector.xy(0, 0), Vector.xy(1, 0), Vector.xy(0, 1))
    vertices:reset()
    triangles:add(1, 2, 3)
    triangles:reset()

    print(#command, #pathData, #enumValues)

    artboard:gamepadConnected(connected)
    artboard:gamepadEvent(changed)
    artboard:gamepadDisconnected(disconnected)

    local layout = GPUBindGroupLayout.new({
        shader = shader,
        fragment = shader,
        groupIndex = 0,
        dynamicUBOs = { 0 },
        label = "shared",
    })
    print(layout)

    local matrixBytes = buffer.create(64)
    Mat4.identity():writeToBuffer(matrixBytes, 0)
    print(buffer.readf32(matrixBytes, 0))

    local packedF32 = buffer.create(16)
    local packedF16 = buffer.create(8)
    buffer.writef32(packedF32, 0, 1.5)
    buffer.writef16(packedF16, 0, 1.5)
    local halfValue: number = buffer.readf16(packedF16, 0)
    buffer.stridedcopy(packedF16, 2, 2, packedF16, 0, 2, 2, 1)
    buffer.convert(packedF16, 0, "f16", packedF32, 0, "f32", 1)
    print(halfValue)

    if canvas.image then
        print(canvas.image.width)
    end
    if gpuCanvas.image then
        print(gpuCanvas.image.height)
    end
end

type LayoutWithoutResize = {}
local _layoutWithoutResize: Layout<LayoutWithoutResize> = {}

return function(): Node<{}>
    return {}
end
