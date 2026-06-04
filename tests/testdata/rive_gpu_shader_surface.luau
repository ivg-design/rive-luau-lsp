type ShaderProbe = {
    gpuCanvas: GPUCanvas,
    shader: Shader?,
    pipeline: GPUPipeline?,
    vertices: GPUBuffer?,
    uniforms: GPUBuffer?,
    sampler: GPUSampler?,
    imageSampler: ImageSampler,
    bindGroup: GPUBindGroup?,
    sourceImage: Image?,
    uniformBytes: buffer,
    vertexCount: number,
}

function init(self: ShaderProbe, context: Context): boolean
    self.gpuCanvas = context:gpuCanvas()
    self.gpuCanvas:resize(256, 256)
    self.imageSampler = ImageSampler("clamp", "clamp", "bilinear")

    local shader = context:shader("gradient_card")
    self.shader = shader
    if not shader then
        return true
    end

    local vertexBytes = buffer.create(48)
    self.vertices = GPUBuffer.new({
        size = buffer.len(vertexBytes),
        usage = "vertex",
        data = vertexBytes,
        immutable = true,
        label = "triangle vertices",
    })

    self.uniformBytes = buffer.create(256)
    self.uniforms = GPUBuffer.new({
        size = buffer.len(self.uniformBytes),
        usage = { "uniform" },
        label = "shader uniforms",
    })

    local layout = GPUBindGroupLayout.new({
        shader = shader,
        groupIndex = 0,
        dynamicUBOs = { 0 },
        label = "material bindings",
    })

    self.pipeline = GPUPipeline.new({
        vertex = { module = shader, entryPoint = "vsMain" },
        fragment = { module = shader, entryPoint = "fsMain" },
        vertexLayout = {{
            stride = 16,
            attributes = {
                { slot = 0, format = "float32x2", offset = 0 },
                { slot = 1, format = "float32x2", offset = 8 },
            },
        }},
        bindGroupLayouts = { layout },
        colorTargets = {{
            format = self.gpuCanvas.format,
            writeMask = "rgba",
            blend = {
                srcColor = "src-alpha",
                dstColor = "one-minus-src-alpha",
                colorOp = "add",
                srcAlpha = "one",
                dstAlpha = "one-minus-src-alpha",
                alphaOp = "add",
            },
        }},
        cullMode = "none",
        winding = "ccw",
        topology = "triangle-list",
        sampleCount = 1,
    })

    self.sampler = GPUSampler.new({
        min = "linear",
        mag = "linear",
        mipmap = "nearest",
        wrapU = "clamp-to-edge",
        wrapV = "clamp-to-edge",
        maxAnisotropy = 1,
    })

    self.sourceImage = context:image("portrait")
    if self.sourceImage and self.uniforms and self.sampler then
        self.bindGroup = GPUBindGroup.new({
            layout = layout,
            ubos = {{ slot = 0, buffer = self.uniforms, offset = 0, size = 64 }},
            textures = {{ slot = 1, view = self.sourceImage:view() }},
            samplers = {{ slot = 2, sampler = self.sampler }},
        })
    end

    self.vertexCount = 3
    return true
end

function advance(self: ShaderProbe, seconds: number): boolean
    if self.uniforms then
        buffer.writef32(self.uniformBytes, 0, seconds)
        self.uniforms:write(self.uniformBytes, 0)
    end
    return true
end

function drawCanvas(self: ShaderProbe)
    if not self.pipeline or not self.vertices then
        return
    end

    local pass = self.gpuCanvas:beginRenderPass({
        color = {{
            loadOp = "clear",
            storeOp = "store",
            clearColor = { 0, 0, 0, 0 },
        }},
    })

    pass:setPipeline(self.pipeline)
    pass:setVertexBuffer(0, self.vertices)
    if self.bindGroup then
        pass:setBindGroup(0, self.bindGroup, { 0 })
    end
    pass:setBlendColor(1, 1, 1, 1)
    pass:draw(self.vertexCount, 1, 0, 0)
    pass:finish()
end

function draw(self: ShaderProbe, renderer: Renderer)
    local gpu = self.gpuCanvas
    renderer:drawImage(gpu.image, self.imageSampler, "srcOver", 1)
end

return function(): Node<ShaderProbe>
    return {
        gpuCanvas = late(),
        shader = nil,
        pipeline = nil,
        vertices = nil,
        uniforms = nil,
        sampler = nil,
        imageSampler = late(),
        bindGroup = nil,
        sourceImage = nil,
        uniformBytes = buffer.create(256),
        vertexCount = 0,
        init = init,
        advance = advance,
        drawCanvas = drawCanvas,
        draw = draw,
    }
end
