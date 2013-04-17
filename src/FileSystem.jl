module FileSystem

immutable PakFile
	pak::String
	off::Uint32
	len::Uint32
end

search_paths = String["/home/jay/q2", "/home/jay/q2renew"]
pak_files = Dict{String,PakFile}()

function scan()
	for path = search_paths
		paks = map(x->path*"/"*x, union(
			filter(x->ismatch(r"pak[0-9]+\.pak$",x), readdir(path)),
			filter(x->ismatch(r"\.pak$",x), readdir(path))
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
		name = lowercase(rstrip(bytestring(read(f, Uint8, 56)), "\0"))
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
	if has(pak_files, fname)
		file = pak_files[fname]
		pak = open(file.pak)
		seek(pak, file.off)
		data = read(pak, Uint8, file.len)
		close(file)
		return IOBuffer(data)
	end
	error("could not open file ", fname)
end

end
