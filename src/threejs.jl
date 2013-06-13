importall BSP
importall ImmutableArrays
importall FileSystem

bspFile = qopen(string("maps/", ARGS[1], ".bsp"))
bsp = read(bspFile, Bsp)
close(bspFile)

function vecstr(v::AbstractVector)
	s = string(v)
	s = s[2:length(s)-1]
	s = replace(s, "f0", "")
end

js = open(string(ARGS[1], ".js"), "w")

write(js, "var geometry = new THREE.Geometry();\n")

for v = bsp.vertices
	write(js, "geometry.vertices.push(new THREE.Vector3("*vecstr(v)*"));\n")
end
for f = bsp.faces
	if length(f.indices) % 3 == 0
		i = 1
		while i < length(f.indices)
			write(js, "geometry.faces.push(new THREE.Face3("*vecstr(f.indices[i:i+2])*"));\n")
			i += 3
		end
	else
		warn(string(length(f.indices)))
	end
end
close(js)

