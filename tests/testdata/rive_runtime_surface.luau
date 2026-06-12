type RuntimeProbe = {
    artboard: Input<Artboard<nil>>,
    vm: ViewModel?,
    image: Image?,
    mat: Mat4,
    canvas: Canvas?,
    promise: Promise<DecodedImage>?,
}

function init(self: RuntimeProbe, context: Context): boolean
    self.vm = context:viewModel()
    self.image = context:image("atlas")
    self.mat = Mat4.perspectiveReverseZ(math.rad(60), 1.6, 0.01)
    self.canvas = context:canvas({width = 64, height = 64})

    local blob = context:blob("encoded")
    if blob then
        local promise = context:decodeImage(blob.data)
        self.promise = promise
        promise:andThen(function(decoded)
            local _bytes: buffer = decoded.data
            local _width: number = decoded.width
            local _height: number = decoded.height
            return decoded
        end)
    end

    if self.vm then
        local index = self.vm:getIndex()
        local imageProperty = self.vm:getImage("portrait")
        local list = self.vm:getList("items")
        if imageProperty then
            imageProperty.value = self.image
        end
        if list then
            local item = list[1]
            list:removeAt(1)
            list:remove(item)
            list:removeAllOf(item)
            list:clear()
            print(index)
        end
    end

    local features = context:features()
    print(features.maxSamples, features.colorBufferHalfFloat)
    return true
end

function keyboardEvent(self: RuntimeProbe, event: KeyboardInvocation): boolean
    return event.phase == "down" and event.key > 0
end

function textEvent(self: RuntimeProbe, event: TextInputInvocation): boolean
    return event.text ~= ""
end

function draw(self: RuntimeProbe, renderer: Renderer)
    local child = self.artboard:instance()
    local tx = Mat2D.withTranslation(Vector.xy(10, 10)) * Mat2D.withRotation(0)
    renderer:transform(tx)
    child:draw(renderer)

    if self.canvas then
        local canvasRenderer = self.canvas:beginFrame()
        canvasRenderer:save()
        canvasRenderer:restore()
        self.canvas:endFrame()
        renderer:drawImage(self.canvas.image, ImageSampler("clamp", "clamp", "bilinear"), "srcOver", 1)
    end
end

function performAction(self: RuntimeProbe, context: ListenerContext)
    if context:isKeyboardEvent() then
        local keyboard = context:asKeyboardEvent()
        if keyboard then
            print(keyboard.phase, keyboard.shift, keyboard.control, keyboard.alt, keyboard.meta)
        end
    elseif context:isTextInput() then
        local text = context:asTextInput()
        if text then
            print(text.text)
        end
    elseif context:isFocus() then
        local focus = context:asFocus()
        if focus then
            print(focus.isFocus)
        end
    elseif context:isGamepad() then
        local gamepad = context:asGamepad()
        if gamepad then
            print(gamepad.deviceId, gamepad.buttonMask, gamepad.axis0)
        end
    elseif context:isReportedEvent() then
        local reported = context:asReportedEvent()
        if reported then
            print(reported.delaySeconds)
        end
    elseif context:isNone() then
        local none = context:asNone()
        print(none)
    end
end

function transform(self: RuntimeProbe, factor: number): number
    return factor * factor
end

function transformValue(self: RuntimeProbe, valueFrom: number, valueTo: number, factor: number): number
    return valueFrom + (valueTo - valueFrom) * transform(self, factor)
end

local function styleAndPathSurface()
    -- Color is a plain number (ARGB packed); raw hex literals are valid Colors
    local rawHex: Color = 0xFFFF0000
    local cc: { number } = Color.toFloat(Color.rgba(255, 0, 0, 128))
    print(cc[1], cc[4])

    local paint = Paint.with({ color = rawHex, style = "fill" })
    local solid = paint:copy({ gradient = false })
    paint.blendMode = "multiply"
    print(solid.feather)

    -- Vector equality operator, z component, and [3] indexing
    local a = Vector.xy(1, 2)
    if a == Vector.xy(1, 2) then
        print(a.z, a[3])
    end

    -- ContourMeasure.next is optional; iteration requires the nil check
    local path = Path.new()
    path:moveTo(Vector.xy(0, 0))
    path:cubicTo(Vector.xy(25, -40), Vector.xy(75, 40), Vector.xy(100, 0))
    local contour = path:contours()
    while contour do
        print(contour.length)
        contour = contour.next
    end
end

styleAndPathSurface()

local _nodeProtocol: Node<RuntimeProbe>? = nil
local _listenerProtocol: ListenerAction<RuntimeProbe>? = nil
local _interpolatorProtocol: Interpolator<RuntimeProbe>? = nil

return function(): any
    return {
        artboard = late() :: Artboard<nil>,
        vm = nil,
        image = nil,
        mat = Mat4.identity(),
        canvas = nil,
        promise = nil,
        init = init,
        draw = draw,
        keyboardEvent = keyboardEvent,
        textEvent = textEvent,
        performAction = performAction,
        transform = transform,
        transformValue = transformValue,
    }
end
