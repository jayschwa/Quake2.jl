module FileSystem

immutable PakFile
	pak::String
	off::Uint32
	len::Uint32
end

search_paths = String[string(ENV["HOME"], "/q2")]
pak_files = Dict{String,PakFile}()

function scan()
	for path = search_paths
		paks = map(x->path*"/"*x, union(
			filter(r"pak[0-9]+\.pak$", readdir(path)),
			filter(r"\.pak$", readdir(path))
		))
		for pak = paks
			scan(pak)
		end
	end
end

function scan(pakpath::String)
	f = open(pakpath)
	if bytestring(read(f, Uint8, 4)) != "PACK"
		error(pakpath, " is not a valid pak")
	end
	offset = read(f, Uint32)
	count = read(f, Uint32) / 64
	seek(f, offset)
	for i = 1:count
		name = lowercase(rstrip(bytestring(read(f, Uint8, 56)), '\0'))
		offset = read(f, Uint32)
		len = read(f, Uint32)
		pak_files[name] = PakFile(pakpath, offset, len)
	end
	@printf("%s (%i files)\n", pakpath, count)
	close(f)
end

scan()

export qopen
function qopen(fname::String)
	fname = lowercase(fname)
	for path = search_paths
		try
			file = open(path * "/" * fname)
			return file
		catch err; end
	end
	if haskey(pak_files, fname)
		file = pak_files[fname]
		pak = open(file.pak)
		seek(pak, file.off)
		data = read(pak, Uint8, file.len)
		close(pak)
		return IOBuffer(data)
	end
	error("could not open file ", fname)
end

end
