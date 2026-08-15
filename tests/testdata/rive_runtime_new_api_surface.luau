-- Probe: callable Luau APIs introduced by runtime-v0.1.262.

local function _checkNewSurface(context: Context, vm: ViewModel)
    local vector = Vector.xyz(1, 2, 3)
    local cross = Vector.cross3(vector, Vector.xyz(0, 1, 0))
    local bytes = buffer.create(32)
    vector:writeToBuffer(bytes, 0)
    vector:writeVec4(bytes, 16, 1)

    local view = Mat4.lookAt(
        Vector.xyz(0, 0, 5),
        Vector.origin(),
        Vector.xyz(0, 1, 0)
    )
    local projection = Mat4.ortho(-1, 1, -1, 1, 0, 10)
    local viewProjection = Mat4.multiply(Mat4.identity(), projection, view)

    local globalNames = context:globalViewModelNames()
    local global = context:globalViewModel("GlobalSettings")
    local font = vm:getFont("titleFont")
    local blob = vm:getBlob("payload")
    local shader = context:shader("lib:Effects/gradient")
    local asset = context:blob("lib:Effects/data")

    if cross.z + viewProjection.m11 + #globalNames > 0 then
        print(global, font, blob, shader, asset)
    end
end

return function(): Node<{}>
    return {}
end
