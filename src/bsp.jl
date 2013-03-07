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

#func (hdr *Header) Check() error {
#	if hdr.Signature != Magic {
#		return ErrFormat
#	}
#	if lumps[Vertices].Length%12 != 0 {
#		return ErrFormat
#	}
#	if lumps[Faces].Length%Uint32(unsafe.Sizeof(Face{})) != 0 {
#		return ErrFormat
#	}
#	if lumps[FaceEdgeTable].Length%Uint32(unsafe.Sizeof(FaceEdge(0))) != 0 {
#		return ErrFormat
#	}
#	if lumps[Edges].Length%Uint32(unsafe.Sizeof(Edge{})) != 0 {
#		return ErrFormat
#	}
#	return nil
#}

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

type Bsp
	vertices::Array{Float32,1}
	indices::Array{Uint16,1}
end

function bspRead(io::IO)
	hdr = read(io, Header)
	lumps = read(io, Lump, 19)

	count = uint32(lumps[Vertices].length / sizeof(Float32))
	seek(io, lumps[Vertices].offset)
	vertices = read(io, Float32, count)

	count = uint32(lumps[Faces].length / sizeof(Face))
	seek(io, lumps[Faces].offset)
	faces = read(io, Face, count)

	count = uint32(lumps[FaceEdgeTable].length / sizeof(FaceEdge))
	seek(io, lumps[FaceEdgeTable].offset)
	face2edge = read(io, FaceEdge, count)

	count = uint32(lumps[Edges].length / sizeof(Edge))
	seek(io, lumps[Edges].offset)
	edges = read(io, Edge, count)

	indices = Array(Uint16, 0)
	for face = faces
		first = face.first_edge + 1
		last = first + face.num_edges - 1
		for idx = face2edge[first:last]
			if idx < 0
				idx -= 1
				push!(indices, edges[-idx].v2)
				push!(indices, edges[-idx].v1)
			else
				idx += 1
				push!(indices, edges[idx].v1)
				push!(indices, edges[idx].v2)
			end
		end
	end

	return Bsp(vertices, indices)
end

#func NewReader(src io.ReadSeeker) (*Reader, error) {
#	hdr := new(Header)
#	src.Seek(0, 0)
#	err := binary.Read(src, binary.LittleEndian, hdr)
#	if err != nil {
#		return nil, err
#	}
#	err = hdr.Check()
#	if err != nil {
#		return nil, err
#	}
#	return &Reader{hdr, src}, nil
#}
#
#func (bsp Reader) Vertices() ([]float32, error) {
#	count := bsp.lumps[Vertices].Length / 4
#	poInts := make([]float32, count)
#	bsp.src.Seek(Int64(bsp.lumps[Vertices].Offset), 0)
#	// FIXME: Handle error
#	_ = binary.Read(bsp.src, binary.LittleEndian, &poInts)
#	return poInts, nil
#}
#
#func (bsp Reader) Indices() ([]Uint16, error) {
#	count := bsp.lumps[Faces].Length / Uint32(unsafe.Sizeof(Face{}))
#	faces := make([]Face, count)
#	bsp.src.Seek(Int64(bsp.lumps[Faces].Offset), 0)
#	binary.Read(bsp.src, binary.LittleEndian, &faces)
#
#	count = bsp.lumps[FaceEdgeTable].Length / Uint32(unsafe.Sizeof(FaceEdge(0)))
#	face2edge := make([]FaceEdge, count)
#	bsp.src.Seek(Int64(bsp.lumps[FaceEdgeTable].Offset), 0)
#	binary.Read(bsp.src, binary.LittleEndian, &face2edge)
#
#	count = bsp.lumps[Faces].Length / Uint32(unsafe.Sizeof(Edge{}))
#	edges := make([]Edge, count)
#	bsp.src.Seek(Int64(bsp.lumps[Edges].Offset), 0)
#	binary.Read(bsp.src, binary.LittleEndian, &edges)
#
#	indices := make([]Uint16, 0)
#
#	for _, face := range faces {
#		from := face.First_edge
#		to := from + Uint32(face.Num_edges)
#		for _, idx := range face2edge[from:to] {
#			if idx < 0 {
#				edge := edges[-idx]
#				indices = append(indices, edge.V2, edge.V1)
#			} else {
#				edge := edges[idx]
#				indices = append(indices, edge.V1, edge.V2)
#			}
#		}
#	}
#
#	return indices, nil
#}
