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

typealias Vertex Vector3{Float32}

function islit(face::Face, vertices::Vector{Vertex}, light::Light)

	# skip faces that have no triangles
	if length(face.indices) < 3
		return false
	end

	# find d component of face's plane
	v = vertices[face.indices[1]+1]
	d = -dot(face.normal, v)

	# is the light radius within range of the face's plane?
	dist = dot(face.normal, light.origin) + d
	if dist < 0 || dist > light.power
		return false
	end

	# TODO: does the light origin project onto the face?
	# TODO: does the light sphere intersect an edge?

	return true
end

end

