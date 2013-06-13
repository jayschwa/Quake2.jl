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

function calcuv(face, point)
	point = cat(1, point, float32(1))
	u = dot(face.u_axis, point) / face.texture.width
	v = dot(face.v_axis, point) / face.texture.height
	return string("new THREE.Vector2(", vecstr([u, v]), ")")
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
			vidxs = f.indices[i:i+2]
			write(js, "geometry.faces.push(new THREE.Face3("*vecstr(vidxs)*"));\n")
			uv1 = calcuv(f, bsp.vertices[vidxs[1]+1])
			uv2 = calcuv(f, bsp.vertices[vidxs[2]+1])
			uv3 = calcuv(f, bsp.vertices[vidxs[3]+1])
			write(js, string("geometry.faceVertexUvs[0].push([", uv1, ",", uv2, ",", uv3, "]);\n"))
			i += 3
		end
	else
		warn(string(length(f.indices)))
	end
end
close(js)

