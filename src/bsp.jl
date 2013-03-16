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

type Lump
	offset::Uint32
	length::Uint32
end

type Header
	signature::Uint32
	version::Uint32
	#lumps::Array{Lump,1}(19)
end

type Face
	plane::Uint16
	plane_side::Uint16
	first_edge::Uint32
	num_edges::Uint16
	tex_info::Uint16
	lightmap_styles::Uint32
	lightmap_offset::Uint32
end

typealias FaceEdge Int32

type Edge
	v1::Uint16
	v2::Uint16
end

immutable Point
	x::Float32
	y::Float32
	z::Float32
end

immutable RGB
	r::Float32
	g::Float32
	b::Float32
end

immutable Light
	origin::Point
	color::RGB
	power::Float32
end

type FaceInfo
	indices::Array{Uint16,1}
	tex_u::Array{Float32,1}
	tex_v::Array{Float32,1}
	#lights::Array{Light,1}
end

type Bsp
	vertices::Array{Float32,1}
	faces::Array{FaceInfo,1}
	lightmaps::Array{Uint8,1}
end

function bspRead(io::IO)
	hdr = read(io, Header)
	lumps = read(io, Lump, 19)

	count = uint32(lumps[Vertices].length / sizeof(Float32))
	seek(io, lumps[Vertices].offset)
	vertices = read(io, Float32, count)

	seek(io, lumps[Lightmaps].offset)
	lightmaps = read(io, Uint8, lumps[Lightmaps].length)

	count = uint32(lumps[Faces].length / sizeof(Face))
	seek(io, lumps[Faces].offset)
	faces = read(io, Face, count)

	count = uint32(lumps[FaceEdgeTable].length / sizeof(FaceEdge))
	seek(io, lumps[FaceEdgeTable].offset)
	face2edge = read(io, FaceEdge, count)

	count = uint32(lumps[Edges].length / sizeof(Edge))
	seek(io, lumps[Edges].offset)
	edges = read(io, Edge, count)

	faceinfos = Array(FaceInfo, 0)
	for face = faces

		seek(io, lumps[TexInfo].offset + face.tex_info * 76)
		tex_u = read(io, Float32, 4)
		tex_v = read(io, Float32, 4)
		tex_flags = read(io, Uint32)

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

		push!(faceinfos, FaceInfo(indices, tex_u, tex_v))
	end

	return Bsp(vertices, faceinfos, lightmaps)
end


