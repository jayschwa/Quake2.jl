module Mesh

importall ImmutableArrays
import GL

type Light
	origin::Vector3{Float32}
	color::Vector3{Float32}
	power::Float32
	Light(origin, color, power) = new(convert(Vector3{Float32}, origin), convert(Vector3{Float32}, color), convert(Float32, power))
end

type Face
	indices::Vector{Uint16}
	normal::Vector3{Float32}
	lights::Vector{Light}
end

export draw
function draw(face::Face)
	GL.DrawElements(GL.TRIANGLES, face.indices)
end

end

