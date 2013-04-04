module File

importall ImmutableArrays
import BSP.Bsp
import Mesh
import Tree

import Base.read
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

immutable Header
	signature::Uint32
	version::Uint32
end

immutable Lump
	offset::Uint32
	length::Uint32
end

immutable Plane
	normal::Vector3{Float32}
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

immutable Node
	plane::Uint32
	front::Int32
	back::Int32
	bbox_min::Vector3{Int16}
	bbox_max::Vector3{Int16}
	first_face::Uint16
	num_faces::Uint16
end

immutable Leaf
	brush_or::Uint32
	cluster::Uint16
	area::Uint16
	bbox_min::Vector3{Int16}
	bbox_max::Vector3{Int16}
	first_face::Uint16
	num_faces::Uint16
	first_brush::Uint16
	num_brushes::Uint16
end

typealias LeafFace Uint16

immutable Edge
	v1::Uint16
	v2::Uint16
end

function build(idx::Integer, nodes::Vector{Node}, planes::Vector{Plane}, leaves::Vector{Tree.Leaf})
	node = nodes[idx]
	if node.front < 0
		front = leaves[-node.front]
	else
		front = build(node.front+1, nodes, planes, leaves)
	end
	if node.back < 0
		back = leaves[-node.back]
	else
		back = build(node.back+1, nodes, planes, leaves)
	end
	normal = planes[node.plane+1].normal
	distance = planes[node.plane+1].distance
	return Tree.Node(front, back, normal, distance)
end

function readlump(io::IO, lump::Lump, t::Type)
	seek(io, lump.offset)
	read(io, t, int(lump.length / sizeof(t)))
end

function read(io::IO, ::Type{Bsp})

	###   Read in header and lump data   #######################################

	hdr   = read(io, Header)
	lumps = read(io, Lump, 19)

	bin_edges    = readlump(io, lumps[Edges],    Edge)
	bin_faces    = readlump(io, lumps[Faces],    Face)
	bin_leaves   = readlump(io, lumps[Leaves],   Leaf)
	bin_nodes    = readlump(io, lumps[Nodes],    Node)
	bin_planes   = readlump(io, lumps[Planes],   Plane)
	bin_vertices = readlump(io, lumps[Vertices], Vector3{Float32})

	face2edge = readlump(io, lumps[FaceEdgeTable], FaceEdge)
	leaf2face = readlump(io, lumps[LeafFaceTable], LeafFace)

	###   Convert File.Faces to Mesh.Faces   ###################################

	faces = Array(Mesh.Face,0)
	for face = bin_faces

		indices = Array(Uint16,0)
		first = face.first_edge + 1
		hub = bin_edges[abs(face2edge[first])+1].v1
		last = first + face.num_edges - 1
		for idx = face2edge[first:last]
			v1 = bin_edges[abs(idx)+1].v1
			v2 = bin_edges[abs(idx)+1].v2
			if idx < 0
				v1, v2 = v2, v1
			end
			if v1 != hub && v2 != hub
				push!(indices, hub)
				push!(indices, v2)
				push!(indices, v1)
			end
		end

		normal = bin_planes[face.plane+1].normal
		if face.plane_side != 0
			normal = -normal
		end

		push!(faces, Mesh.Face(indices, normal, Array(Mesh.Light,0)))
	end

	###   Convert File.Leaves to Tree.Leaves   #################################

	leaves = Array(Tree.Leaf,0)
	for leaf = bin_leaves
		first = leaf.first_face + 1
		last = first + leaf.num_faces - 1
		indices = leaf2face[first:last]
		leaf_faces = Array(Mesh.Face,0)
		for i = indices
			push!(leaf_faces, faces[i+1])
		end
		push!(leaves, Tree.Leaf(Array(Tree.Leaf,0), leaf_faces))
	end

	###   Populate Tree.Leaves visibility info   ###############################

	for leaf = leaves
		push!(leaf.visible, leaf)
	end

	###   Build BSP tree   #####################################################

	tree = build(1, bin_nodes, bin_planes, leaves)

	###   Parse entity data   ##################################################

	# Read entity lump
	seek(io, lumps[Entities].offset)
	entityLump = bytestring(read(io, Uint8, lumps[Entities].length-1))
	entities = Array(Dict{String, String},0)

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

	###   Build list of lights from entity data   ##############################

	lights = Array(Mesh.Light,0)
	for ent = entities
		if ent["classname"] != "light"
			continue
		end
		if has(ent, "origin")
			origin = split(ent["origin"])
			origin = Vector3{Float32}(float32(origin[1]), float32(origin[2]), float32(origin[3]))
		else
			warn("light has no origin")
			continue
		end
		if has(ent, "color")
			color = split(ent["color"])
			color = Vector3{Float32}(float32(color[1]), float32(color[2]), float32(color[3]))
			color /= max(color)
		else
			color = Vector3{Float32}(1.0, 1.0, 1.0)
		end
		if has(ent, "light")
			power = float32(ent["light"])
		else
			power = float32(300)
		end
		power *= 1.33
		push!(lights, Mesh.Light(origin, color, power))
	end

	###   Associate lights with visible faces   ################################

	for light = lights
		for leaf = search(tree, light.origin).visible
			for face = leaf.faces
				lit = false
				for i = face.indices
					vertex = bin_vertices[i+1]
					if norm(vertex - light.origin) < light.power
						lit = true
						break
					end
				end
				if lit
					push!(face.lights, light)
				end
			end
		end
	end

	light_stats = Array(Int,0)
	for face = faces
		push!(light_stats, length(face.lights))
	end

	return Bsp(tree, entities, bin_vertices, max(light_stats))
end

end

