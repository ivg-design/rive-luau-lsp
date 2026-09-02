-- Static acceptance fixture for callable members present in the live Rive
-- scripting reference on 2026-09-01. Gamepad callbacks are reference-
-- confirmed (Coming soon) rather than runtime-triggered by this fixture.

local function _checkMatrices(a2: Mat2D, b2: Mat2D, a4: Mat4, b4: Mat4)
    local equal2: boolean = a2 == b2
    local equal4: boolean = a4 == b4
    print(equal2, equal4)
end

local function _checkAudio(sound: AudioSound)
    sound:pause()
    sound:resume()
    sound:play()
end

local function _checkReferenceEvents(
    pointer: PointerEvent,
    keyboard: KeyboardEvent,
    textInput: TextInput,
    focus: FocusEvent
)
    local pointerType: PointerType = pointer.type
    local keyPhase: KeyPhase = keyboard.phase
    print(
        pointerType,
        pointer.position,
        pointer.id,
        keyboard.key,
        keyboard.shift,
        keyboard.control,
        keyboard.alt,
        keyboard.meta,
        keyPhase,
        textInput.text,
        focus.isFocus
    )

    -- These prior LSP names remain compatible aliases.
    local legacyKeyboard: KeyboardInvocation = keyboard
    local legacyText: TextInputInvocation = textInput
    local legacyFocus: FocusInvocation = focus
    print(legacyKeyboard, legacyText, legacyFocus)
end

local function _checkRuntimeReported(event: ReportedEventInvocation)
    -- The live Editor ReportedEvent is empty. Keep the exact runtime-v0.1.344
    -- invocation payload separate from the current Editor event type.
    print(event.delaySeconds)
end

local function checkConnected(event: GamepadConnected)
    local mapping: GamepadMappingKind = event.mapping
    local pressed = event:buttonPressed(1)
    local value = event:buttonValue(1)
    local axis = event:axis(1)
    print(
        mapping,
        pressed,
        value,
        axis,
        event.deviceId,
        event.buttonMask,
        event.buttons,
        event.axes,
        event.isStandardMapping,
        event.gamepadMapping,
        event.west,
        event.south,
        event.north,
        event.east,
        event.leftShoulder,
        event.rightShoulder,
        event.back,
        event.forward,
        event.leftStickButton,
        event.rightStickButton,
        event.dpadUp,
        event.dpadDown,
        event.dpadLeft,
        event.dpadRight,
        event.start,
        event.leftStick,
        event.rightStick,
        event.leftTrigger,
        event.rightTrigger,
        event.leftTriggerPressed,
        event.rightTriggerPressed
    )
end

local function checkEvent(event: GamepadEvent)
    local mapping: GamepadMappingKind = event.mapping
    local pressed = event:buttonPressed(1)
    local value = event:buttonValue(1)
    local axis = event:axis(1)
    print(
        mapping,
        pressed,
        value,
        axis,
        event.changeKind,
        event.changeIndex,
        event.changeValue,
        event.hasStandardButtonIntent,
        event.hasStandardAxisIntent,
        event.intentButton,
        event.intentAxis,
        event.deviceId,
        event.buttonMask,
        event.buttons,
        event.axes,
        event.isStandardMapping,
        event.gamepadMapping,
        event.west,
        event.south,
        event.north,
        event.east,
        event.leftShoulder,
        event.rightShoulder,
        event.back,
        event.forward,
        event.leftStickButton,
        event.rightStickButton,
        event.dpadUp,
        event.dpadDown,
        event.dpadLeft,
        event.dpadRight,
        event.start,
        event.leftStick,
        event.rightStick,
        event.leftTrigger,
        event.rightTrigger,
        event.leftTriggerPressed,
        event.rightTriggerPressed
    )
end

local function _checkListener(context: ListenerContext)
    if context:isPointerEvent() then
        local pointer: PointerEvent? = context:asPointerEvent()
        if pointer then
            local pointerType: PointerType = pointer.type
            print(pointerType)
        end
    end
    if context:isKeyboardEvent() then
        local keyboard: KeyboardEvent? = context:asKeyboardEvent()
        local legacyKeyboard: KeyboardInvocation? = keyboard
        if keyboard then
            local phase: KeyPhase = keyboard.phase
            print(phase, legacyKeyboard)
        end
    end
    if context:isTextInput() then
        local textInput: TextInput? = context:asTextInput()
        local legacyText: TextInputInvocation? = textInput
        if textInput then
            print(textInput.text, legacyText)
        end
    end
    if context:isFocus() then
        local focus: FocusEvent? = context:asFocus()
        local legacyFocus: FocusInvocation? = focus
        if focus then
            print(focus.isFocus, legacyFocus)
        end
    end
    if context:isReportedEvent() then
        local reported: ReportedEvent? = context:asReportedEvent()
        print(reported)
    end
    if context:isViewModelChange() then
        local changed: ViewModelChange? = context:asViewModelChange()
        local legacyChanged: ViewModelChangeInvocation? = changed
        print(changed, legacyChanged)
    end
    if context:isNone() then
        local none: NoneEvent? = context:asNone()
        local legacyNone: NoneInvocation? = none
        print(none, legacyNone)
    end

    if context:isGamepadConnected() then
        local connected = context:asGamepadConnected()
        if connected then
            checkConnected(connected)
        end
    end
    if context:isGamepadEvent() then
        local event = context:asGamepadEvent()
        if event then
            checkEvent(event)
        end
    end
    if context:isGamepadDisconnected() then
        local disconnected = context:asGamepadDisconnected()
        if disconnected then
            print(disconnected.deviceId)
        end
    end

end

type ReferenceNode = {}

function pointerDown(self: ReferenceNode, event: PointerEvent)
    local pointerType: PointerType = event.type
    print(pointerType)
end

function keyboardEvent(self: ReferenceNode, event: KeyboardEvent): boolean?
    local phase: KeyPhase = event.phase
    print(phase)
    return nil
end

function textEvent(self: ReferenceNode, event: TextInput): boolean?
    print(event.text)
    return nil
end

function gamepadConnected(self: ReferenceNode, event: GamepadConnected)
    checkConnected(event)
end

function gamepadEvent(self: ReferenceNode, event: GamepadEvent)
    checkEvent(event)
end

function gamepadDisconnected(self: ReferenceNode, event: GamepadDisconnected)
    print(event.deviceId)
end

return function(): Node<ReferenceNode>
    return {
        pointerDown = pointerDown,
        keyboardEvent = keyboardEvent,
        textEvent = textEvent,
        gamepadConnected = gamepadConnected,
        gamepadEvent = gamepadEvent,
        gamepadDisconnected = gamepadDisconnected,
    }
end
