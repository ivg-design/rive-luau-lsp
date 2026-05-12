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

    return context:preferredCanvasFormat() ~= ""
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
