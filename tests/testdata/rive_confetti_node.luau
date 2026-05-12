type Particle = {
    position: Vector,
    velocity: Vector,
    rotation: number,
    rotationSpeed: number,
    age: number,
    lifespan: number,
    artboard: Artboard<nil>,
}

type Confetti = {
    flowRate: Input<number>,
    lifespan: Input<number>,
    spread: Input<number>,
    velocity: Input<number>,
    confettiArtboard: Input<Artboard<nil>>,
    alignToVelocity: Input<boolean>,

    particles: {Particle},
    currentCursorPosition: Vector?,
    prevCursorPosition: Vector?,
    cursorVelocity: Vector,
    spawnAccumulator: number,
    isPointerDown: boolean,
}

local function createParticle(
    position: Vector,
    cursorVelocity: Vector,
    lifespan: number,
    spread: number,
    velocityScale: number,
    sourceArtboard: Artboard<nil>
): Particle
    local inheritedVelocity = cursorVelocity * velocityScale
    local spreadTransform = Mat2D.withRotation((math.random() - 0.5) * math.rad(spread))
    local finalVelocity = spreadTransform * inheritedVelocity
    local artboardInstance = sourceArtboard:instance()

    return {
        position = position,
        velocity = finalVelocity,
        rotation = math.random() * math.pi * 2,
        rotationSpeed = (math.random() - 0.5) * 10,
        age = 0,
        lifespan = lifespan * (0.8 + math.random() * 0.4),
        artboard = artboardInstance,
    }
end

local function drawConfettiPiece(renderer: Renderer, particle: Particle, alignToVelocity: boolean)
    local hw = particle.artboard.width * 0.5
    local hh = particle.artboard.height * 0.5
    local rotation: number

    if alignToVelocity then
        rotation = math.atan2(particle.velocity.y, particle.velocity.x)
    else
        rotation = particle.rotation
    end

    local transform = Mat2D.withTranslation(particle.position)
        * Mat2D.withRotation(rotation)
        * Mat2D.withTranslation(-hw, -hh)

    renderer:save()
    renderer:transform(transform)
    particle.artboard:draw(renderer)
    renderer:restore()
end

local function resetPointerState(self: Confetti)
    self.isPointerDown = false
    self.currentCursorPosition = nil
    self.prevCursorPosition = nil
    self.cursorVelocity = Vector.origin()
    self.spawnAccumulator = 0
end

function init(self: Confetti, context: Context): boolean
    self.particles = {}
    self.currentCursorPosition = nil
    self.prevCursorPosition = nil
    self.cursorVelocity = Vector.origin()
    self.spawnAccumulator = 0
    self.isPointerDown = false
    return true
end

function advance(self: Confetti, seconds: number): boolean
    local gravity = Vector.xy(0, 200)
    local drag = 0.98
    local curr = self.currentCursorPosition
    local prev = self.prevCursorPosition

    if self.isPointerDown and curr ~= nil and prev ~= nil and seconds > 0 then
        local rawVelocity = (curr - prev) * (1 / seconds)
        local smooth = 1 - (0.05 ^ seconds)
        self.cursorVelocity = Vector.lerp(self.cursorVelocity, rawVelocity, smooth)
    end

    self.prevCursorPosition = self.currentCursorPosition

    if self.isPointerDown and curr ~= nil and Vector.lengthSquared(self.cursorVelocity) > 500 then
        self.spawnAccumulator += self.flowRate * seconds

        while self.spawnAccumulator >= 1 do
            self.spawnAccumulator -= 1
            table.insert(self.particles, createParticle(curr, self.cursorVelocity, self.lifespan, self.spread, self.velocity, self.confettiArtboard))
        end
    end

    local i = 1
    while i <= #self.particles do
        local p = self.particles[i]
        p.age += seconds

        if p.age >= p.lifespan then
            local last = #self.particles
            self.particles[i] = self.particles[last]
            table.remove(self.particles, last)
        else
            p.velocity = (p.velocity + gravity * seconds) * drag
            p.position = p.position + p.velocity * seconds
            p.rotation += p.rotationSpeed * seconds
            p.rotationSpeed *= 0.99
            p.artboard:advance(seconds)
            i += 1
        end
    end

    return true
end

function pointerDown(self: Confetti, event: PointerEvent)
    resetPointerState(self)
    self.isPointerDown = true
    self.currentCursorPosition = event.position
    event:hit()
end

function pointerMove(self: Confetti, event: PointerEvent)
    self.currentCursorPosition = event.position
end

function pointerUp(self: Confetti, event: PointerEvent)
    resetPointerState(self)
end

function pointerExit(self: Confetti, event: PointerEvent)
    resetPointerState(self)
end

function draw(self: Confetti, renderer: Renderer)
    for _, particle in ipairs(self.particles) do
        drawConfettiPiece(renderer, particle, self.alignToVelocity)
    end
end

return function(): Node<Confetti>
    return {
        flowRate = 30,
        lifespan = 2,
        spread = 45,
        velocity = 1,
        confettiArtboard = late(),
        alignToVelocity = false,

        particles = {},
        currentCursorPosition = nil,
        prevCursorPosition = nil,
        cursorVelocity = Vector.origin(),
        spawnAccumulator = 0,
        isPointerDown = false,

        init = init,
        advance = advance,
        draw = draw,
        pointerDown = pointerDown,
        pointerMove = pointerMove,
        pointerUp = pointerUp,
        pointerExit = pointerExit,
    }
end
