module File

importall Images
importall ImmutableArrays
importall FileSystem
importall Textures
import GL
import BSP.Bsp
import ..Mesh
import ..Tree

import Base:read,sizeof

const Entities       = 1
const Planes         = 2
const Vertices       = 3
const Visibility     = 4
const Nodes          = 5
const TexInfos       = 6
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

typealias Vertex Vector3{Float32}

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

immutable VisOffsets
	sight::Uint32
	sound::Uint32
end

immutable TexInfo
	u::Vector4{Float32}
	v::Vector4{Float32}
	flags::Uint32
	value::Uint32
	name::ASCIIString
	next::Uint32
end
function read(io, ::Type{TexInfo})
	u = read(io, Vector4{Float32})
	v = read(io, Vector4{Float32})
	flags = read(io, Uint32)
	value = read(io, Uint32)
	name = lowercase(rstrip(bytestring(read(io, Uint8, 32)), "\0"))
	next = read(io, Uint32)
	return TexInfo(u,v,flags,value,name,next)
end
sizeof(::Type{TexInfo}) = 76

read(s::IO, t::DataType) = t(ntuple(length(t.types), x->read(s, t.types[x]))...)

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

function readheightmap(name::String)
	img = imread(string("/home/jay/q2renew/textures/", name, ".height.png"))
	width, height = size(img)[2:3]
	gray = uint8(convert(Array, img))[:,:,1]
	handle = GL.GenTexture()

	# create normals from heights
	normals = Array(Uint8, 0)
	for w = 1:width
		wp = w-1>=1 ? w-1 : width
		wn = w+1<=width ? w+1 : 1
		for h = 1:height
			hp = h-1>=1 ? h-1 : height
			hn = h+1<=height ? h+1 : 1
			x = int(gray[w,hp] - gray[w,hn]) / 32.0
			y = int(gray[wp,h] - gray[wn,h]) / 32.0
			n = Vector3(x,y,1.0)
			n /= norm(n)
			n = uint8(n * (255/2) + (255/2))
			push!(normals, n[1])
			push!(normals, n[2])
			push!(normals, n[3])
			push!(normals, gray[w,h])
		end
	end

	# upload image data to GPU
	GL.BindTexture(GL.TEXTURE_2D, handle)
	GL.TexImage2D(GL.TEXTURE_2D, GL.RGBA, width, height, GL.RGBA, normals)
	GL.GenerateMipmap(GL.TEXTURE_2D)
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR)
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR)
	GL.TexParameteri(GL.TEXTURE_2D, 0x84FE, 8) # anisotropic filtering
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT)
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT)
	GL.BindTexture(GL.TEXTURE_2D, 0)
	return handle
end

function read(io::IO, ::Type{Bsp})

	###   Read in header and lump data   #######################################

	hdr   = read(io, Header)
	lumps = read(io, Lump, 19)

	bin_edges    = readlump(io, lumps[Edges],      Edge)
	bin_faces    = readlump(io, lumps[Faces],      Face)
	bin_leaves   = readlump(io, lumps[Leaves],     Leaf)
	bin_nodes    = readlump(io, lumps[Nodes],      Node)
	bin_planes   = readlump(io, lumps[Planes],     Plane)
	bin_texinfos = readlump(io, lumps[TexInfos],   TexInfo)
	bin_vertices = readlump(io, lumps[Vertices],   Vertex)
	bin_vis      = readlump(io, lumps[Visibility], Uint8)

	face2edge = readlump(io, lumps[FaceEdgeTable], FaceEdge)
	leaf2face = readlump(io, lumps[LeafFaceTable], LeafFace)

	seek(io, lumps[Visibility].offset)
	num_clusters = read(io, Uint32)
	vis_offsets = read(io, VisOffsets, num_clusters)

	###   Convert File.TexInfo to Mesh.Textures   ##############################

	default_normal_map = GL.GenTexture()
	GL.BindTexture(GL.TEXTURE_2D, default_normal_map)
	GL.TexImage2D(GL.TEXTURE_2D, GL.RGBA, 1, 1, GL.RGBA, Uint8[127,127,255,127])
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST)
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST)
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT)
	GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT)
	GL.BindTexture(GL.TEXTURE_2D, 0)

	textures = Dict{String,Mesh.Texture}()
	for texinfo = bin_texinfos
		if !has(textures, texinfo.name)
			if texinfo.flags > 0
				println(texinfo.flags, ", ", texinfo.value)
			end

			f = qopen(string("textures/", texinfo.name, ".wal"))
			img = imread(f, Textures.WAL)
			close(f)

			width = uint32(size(img)[2])
			height = uint32(size(img)[3])
			diffuse = GL.GenTexture()

			# upload image data to GPU
			GL.BindTexture(GL.TEXTURE_2D, diffuse)
			GL.TexImage2D(GL.TEXTURE_2D, GL.RGB, width, height, GL.RGB, uint8(img[:]))
			GL.GenerateMipmap(GL.TEXTURE_2D)
			GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR)
			GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR)
			GL.TexParameteri(GL.TEXTURE_2D, 0x84FE, 8) # anisotropic filtering
			GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT)
			GL.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT)
			GL.BindTexture(GL.TEXTURE_2D, 0)

			normal = default_normal_map
			try
				normal = readheightmap(texinfo.name)
				print("[h] ")
			catch e
				print("[ ] ")
			end

			textures[texinfo.name] = Mesh.Texture(diffuse, normal, width, height, texinfo.flags)
			println(texinfo.name)
		end
	end

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

		texinfo = bin_texinfos[face.tex_info+1]
		u = texinfo.u
		v = texinfo.v
		tex = textures[texinfo.name]

		push!(faces, Mesh.Face(indices, normal, tex, u, v, Array(Mesh.Light,0)))
	end

	###   Convert File.Leaves to Tree.Leaves   #################################

	leaves_in_cluster = Dict{Uint16,Vector{Tree.Leaf}}()

	leaves = Array(Tree.Leaf,0)
	for leaf = bin_leaves
		leaf_faces = Array(Mesh.Face,0)
		first = leaf.first_face + 1
		last = first + leaf.num_faces - 1
		for i = leaf2face[first:last]
			face = faces[i+1]
			if contains(leaf_faces, face)
				warn("duplicate face in leaf")
			else
				push!(leaf_faces, face)
			end
		end
		c = leaf.cluster
		if !has(leaves_in_cluster, c)
			leaves_in_cluster[c] = Array(Tree.Leaf,0)
		end
		leaf = Tree.Leaf(leaf_faces)
		push!(leaves, leaf)
		push!(leaves_in_cluster[c], leaf)
	end

	###   Populate Tree.Leaves visibility info   ###############################

	faces_in_cluster = Dict{Uint16,Vector{Mesh.Face}}()
	for tup = leaves_in_cluster
		c = tup[1]
		cluster_leaves = tup[2]
		visible_faces = Array(Mesh.Face,0)
		for leaf = cluster_leaves
			for face = leaf.faces
				push!(visible_faces, face)
			end
		end
		faces_in_cluster[c] = unique(visible_faces)
	end

	faces_from_cluster = Dict{Uint16,Vector{Mesh.Face}}()
	for tup = faces_in_cluster
		c = tup[1]                   # this cluster index
		visible_faces = copy(tup[2])

		if c == uint16(-1)
			continue
		end

		v = vis_offsets[c+1].sight+1 # pvs buffer index
		k = 0                        # other cluster index
		while k < num_clusters
			if bin_vis[v] == 0
				v += 1
				k += 8 * bin_vis[v]
			else
				for bit = 0:7
					if bin_vis[v] & (1 << bit) != 0 && has(faces_in_cluster, k)
						for face = faces_in_cluster[k]
							push!(visible_faces, face)
						end
					end
					k += 1
				end
			end
			v += 1
		end
		faces_from_cluster[c] = unique(visible_faces)
	end

	for i = 1:length(leaves)
		leaf = leaves[i]
		c = bin_leaves[i].cluster
		if c != uint16(-1)
			leaf.faces = faces_from_cluster[c]
		else
			leaf.faces = faces
		end
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
			name = lstrip(strip(fieldStr[1], '"'), "_")
			value = strip(fieldStr[2], '"')
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
		power *= 1.5
		push!(lights, Mesh.Light(origin, color, power))
	end

	###   Associate lights with visible faces   ################################

	for light = lights
		for face = search(tree, light.origin).faces
			lit = Mesh.islit(face, bin_vertices, light)
			if lit && !contains(face.lights, light)
				push!(face.lights, light)
			end
		end
	end

	###   Calculate leaf statistics   ##########################################

	leaf_stats = Array(Int,0)
	for leaf = leaves
		if length(leaf.faces) > 0
			push!(leaf_stats, length(leaf.faces))
		end
	end
	println("visible faces per non-empty leaf:")
	println("min:    ", min(leaf_stats))
	println("mean:   ", mean(leaf_stats))
	println("median: ", median(leaf_stats))
	println("max:    ", max(leaf_stats))

	###   Calculate light statistics   #########################################

	light_stats = Array(Int,0)
	for face = faces
		push!(light_stats, length(face.lights))
	end
	println("lights per face:")
	println("min:    ", min(light_stats))
	println("mean:   ", mean(light_stats))
	println("median: ", median(light_stats))
	println("max:    ", max(light_stats))

	return Bsp(tree, entities, bin_vertices, max(light_stats))
end

end

