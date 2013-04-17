module Mesh

importall ImmutableArrays
import GL

type Texture
	diffuse::GL.Texture
	normal::GL.Texture
	width::Uint32
	height::Uint32
	flags::Uint32
end

type Light
	origin::Vector3{Float32}
	color::Vector3{Float32}
	power::Float32
	Light(origin, color, power) = new(convert(Vector3{Float32}, origin), convert(Vector3{Float32}, color), convert(Float32, power))
end

type Face
	indices::Vector{Uint16}
	normal::Vector3{Float32}
	texture::Texture
	u_axis::Vector4{Float32}
	v_axis::Vector4{Float32}
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

	# is light radius within range of face's plane?
	dist = dot(face.normal, light.origin) + d
	if dist < 0 || dist > light.power
		return false
	end

	# project light onto face's plane
	projected_origin = light.origin - face.normal * dist
	projected_power = light.power * sin(acos(dist / light.power))

	# check if projected light radius intersects any triangles in face
	for tri = 0:floor(length(face.indices)/3)-1
		inside_triangle = true
		for edge = 0:2
			i1 = tri*3+edge+1
			i2 = tri*3+(edge+1)%3+1
			v1 = vertices[face.indices[i1]+1]
			v2 = vertices[face.indices[i2]+1]
			edge_normal = cross(face.normal, v1-v2)
			edge_normal /= norm(edge_normal)
			d = -dot(edge_normal, v1)
			dist = dot(edge_normal, projected_origin) + d
			if abs(dist) < projected_power
				return true
			end
			if dist > 0
				inside_triangle = false
			end
		end
		if inside_triangle
			return true
		end
	end

	return false
end

end

