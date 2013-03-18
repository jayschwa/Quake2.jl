function GetUniformLocation(prog::Program, name::String)
	ret = ccall( (:glGetUniformLocation, lib), Uniform,
		(Program, Ptr{GLchar}), prog, bytestring(name))
	if ret < 0
		GetError()
		error("uniform not found")
	else
		return ret
	end
end

# TODO: All uniform functions

for (T,t) in ((Float32, "f"), (Int32, "i"), (Uint32, "ui"))
	@eval begin
		uniform!(u::Uniform, v1::$T) =
			ccall(($(string("glUniform1", t)), lib), Void, (Uniform, $T), u, v1)
		uniform!(u::Uniform, v1::$T, v2::$T) =
			ccall(($(string("glUniform2", t)), lib), Void, (Uniform, $T, $T), u, v1, v2)
		uniform!(u::Uniform, v1::$T, v2::$T, v3::$T) =
			ccall(($(string("glUniform3", t)), lib), Void, (Uniform, $T, $T, $T), u, v1, v2, v3)
		uniform!(u::Uniform, v1::$T, v2::$T, v3::$T, v4::$T) =
			ccall(($(string("glUniform4", t)), lib), Void, (Uniform, $T, $T, $T, $T), u, v1, v2, v3, v4)
	end
end

function UniformMatrix4fv(u::Uniform, data::Array{Float32,2})
	ccall( (:glUniformMatrix4fv, lib), Void,
		(Uniform, GLsizei, GLboolean, Ptr{GLfloat}),
		u, 1, false, data)
	GetError()
end

