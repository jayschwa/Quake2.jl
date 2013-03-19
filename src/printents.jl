importall Base
read(s::IO, t::DataType) = t(ntuple(length(t.types), x->read(s, t.types[x]))...)

const Entities       = 1

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

function bspPrintEntities(io::IO)
	hdr = read(io, Header)
	lumps = read(io, Lump, 19)

	seek(io, lumps[Entities].offset)
	entityLump = bytestring(read(io, Uint8, lumps[Entities].length-1))
	entities = Array(Dict{String, String}, 0)
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
		if length(dict) > 0
			push!(entities, dict)
		end
	end
	for entity = entities
		println(entity)
	end
end

bspPrintEntities(open(ARGS[1]))

