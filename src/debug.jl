import GL

while true
	dist = float64(10)
	println(typeof(dist))
	println(dist)

	println(typeof(GL.GLSLType3{Float32}(0.0f, 0.0f, dist)))
	GL.GLSLType3{Float32}(0.0f, 0.0f, dist)

	println("success")
end

