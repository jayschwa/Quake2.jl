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

function UniformMatrix4fv(u::Uniform, data::Array{Float32, 2})
	ccall( (:glUniformMatrix4fv, lib), Void,
		(Uniform, GLsizei, GLboolean, Ptr{Float32}),
		u, 1, false, data)
	GetError()
end

