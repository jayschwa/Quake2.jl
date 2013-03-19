importall Base
read(s::IO, t::DataType) = t(ntuple(length(t.types), x->read(s, t.types[x]))...)

const Entities       = 1
const Planes         = 2
const Vertices       = 3
const Visibility     = 4
const Nodes          = 5
const TexInfo        = 6
const Faces          = 7
const Lightmaps      = 8
const Leaves         = 9
const LeafFaceTable  = 10
const LeafBrushTable = 11
const Edges          = 12
const FaceEdgeTable  = 13
const Models         = 14
const Brushes        = 15
const BrushSides     = 16
const Pop            = 17
const Areas          = 18
const AreaPortals    = 19

const Magic = "IBSP"

immutable Lump
	offset::Uint32
	length::Uint32
end

immutable Header
	signature::Uint32
	version::Uint32
	#lumps::Array{Lump,1}(19)
end

immutable Light
	origin::GL.Vec3
	color::GL.Vec3
	power::Float32
end

immutable Plane
	normal::GL.Vec3
	distance::Float32
	type_::Uint32
end

immutable Face
	plane::Uint16
	plane_side::Uint16
	first_edge::Uint32
	num_edges::Uint16
	tex_info::Uint16
	lightmap_styles::Uint32
	lightmap_offset::Uint32
end

typealias FaceEdge Int32

immutable Edge
	v1::Uint16
	v2::Uint16
end

type FaceInfo
	indices::Array{Uint16,1}
	tex_u::Array{Float32,1}
	tex_v::Array{Float32,1}
	normal::GL.Vec3
	lights::Array{Light,1}
end

type Bsp
	entities::Array{Dict{String,String},1}
	vertices::Array{GL.Vec3,1}
	faces::Array{FaceInfo,1}
end

function bspRead(io::IO)
	hdr = read(io, Header)
	lumps = read(io, Lump, 19)

	# Read entity lump
	seek(io, lumps[Entities].offset)
	entityLump = bytestring(read(io, Uint8, lumps[Entities].length-1))
	entities = Array(Dict{String, String}, 0)

	# Create a dictionary for each entity
	for entity = split(entityLump, ['{', '}'])
		entity = strip(entity)
		if length(entity) < 1 # TODO: remove this w/ regex
			continue
		end
		dict = Dict{String, String}()
		for field = split(entity, '\n')
			fieldStr = split(strip(field), "\" \"")
			name = lstrip(strip(fieldStr[1], "\""), "_")
			value = strip(fieldStr[2], "\"")
			dict[name] = value
		end
		if length(dict) < 1
			continue
		elseif !has(dict, "classname")
			warn("entity has no classname")
			continue
		else
			push!(entities, dict)
		end
	end

	# Build list of lights
	bsp_lights = Array(Light, 0)
	for ent = entities
		if ent["classname"] != "light"
			continue
		end
		if has(ent, "origin")
			origin = split(ent["origin"])
			origin = GL.Vec3(float32(origin[1]), float32(origin[2]), float32(origin[3]))
		else
			warn("light has no origin")
			continue
		end
		if has(ent, "light")
			power = float32(ent["light"])
		else
			power = float32(200)
		end
		color = GL.Vec3(1, 1, 1)
		push!(bsp_lights, Light(origin, color, power))
	end

	count = uint32(lumps[Vertices].length / sizeof(GL.Vec3))
	seek(io, lumps[Vertices].offset)
	vertices = read(io, GL.Vec3, count)

	count = uint32(lumps[Planes].length / sizeof(Plane))
	seek(io, lumps[Planes].offset)
	planes = read(io, Plane, count)

	count = uint32(lumps[Faces].length / sizeof(Face))
	seek(io, lumps[Faces].offset)
	faces = read(io, Face, count)

	count = uint32(lumps[FaceEdgeTable].length / sizeof(FaceEdge))
	seek(io, lumps[FaceEdgeTable].offset)
	face2edge = read(io, FaceEdge, count)

	count = uint32(lumps[Edges].length / sizeof(Edge))
	seek(io, lumps[Edges].offset)
	edges = read(io, Edge, count)

	light_stats = Array(Int, 0)

	faceinfos = Array(FaceInfo, 0)
	for face = faces

		seek(io, lumps[TexInfo].offset + face.tex_info * 76)
		tex_u = read(io, Float32, 4)
		tex_v = read(io, Float32, 4)
		tex_flags = read(io, Uint32)

		normal = planes[face.plane+1].normal
		if face.plane_side != 0
			normal = -normal
		end
		normal /= norm(normal)

		# Skip SKY, NODRAW, and TRANS faces
		if tex_flags & 0x4 != 0 || tex_flags & 0x10 != 0 ||
		   tex_flags & 0x20 != 0 || tex_flags & 0x80 != 0
			continue
		end

		indices = Array(Uint16, 0)
		first = face.first_edge + 1
		hub = edges[abs(face2edge[first])+1].v1
		last = first + face.num_edges - 1

		for idx = face2edge[first:last]
			v1 = edges[abs(idx)+1].v1
			v2 = edges[abs(idx)+1].v2
			if idx < 0
				v1, v2 = v2, v1
			end
			if v1 != hub && v2 != hub
				push!(indices, hub)
				push!(indices, v2)
				push!(indices, v1)
			end
		end

		# Determine which lights affect this face
		face_lights = Array(Light, 0)
		for light = bsp_lights
			in_range = false
			for idx = indices
				vertex = vertices[idx+1]
				if norm(vertex - light.origin) < light.power
					in_range = true
					break
				end
			end
			if in_range
				push!(face_lights, light)
			end
		end
		push!(light_stats, length(face_lights))

		push!(faceinfos, FaceInfo(indices, tex_u, tex_v, normal, face_lights))
	end

	println("lights:")
	println("min:    ", min(light_stats))
	println("mean:   ", mean(light_stats))
	println("median: ", median(light_stats))
	println("max:    ", max(light_stats))

	return Bsp(entities, vertices, faceinfos)
end


