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

function Uniform4f(u::Uniform, data::Array{Float32,1})
	ccall( (:glUniform4fv, lib), Void,
		(Uniform, GLsizei, Ptr{GLfloat}),
		u, 1, data)
	GetError()
end

function UniformMatrix4fv(u::Uniform, data::Array{Float32,2})
	ccall( (:glUniformMatrix4fv, lib), Void,
		(Uniform, GLsizei, GLboolean, Ptr{GLfloat}),
		u, 1, false, data)
	GetError()
end

