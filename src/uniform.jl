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

function Uniform2f(u::Uniform, data::Array{Float32,1})
	ccall( (:glUniform2fv, lib), Void,
		(Uniform, GLsizei, Ptr{GLfloat}),
		u, 1, data)
	GetError()
end

function Uniform4f(u::Uniform, data::Array{Float32,1})
	ccall( (:glUniform4fv, lib), Void,
		(Uniform, GLsizei, Ptr{GLfloat}),
		u, 1, data)
	GetError()
end

function Uniform1i(u::Uniform, data::Integer)
	ccall( (:glUniform1i, lib), Void, (Uniform, GLint), u, data)
	GetError()
end

function Uniform2ui(u::Uniform, data::Array{Uint32,1})
	ccall( (:glUniform2uiv, lib), Void,
		(Uniform, GLsizei, Ptr{GLuint}),
		u, 1, data)
	GetError()
end

function UniformMatrix4fv(u::Uniform, data::Array{Float32,2})
	ccall( (:glUniformMatrix4fv, lib), Void,
		(Uniform, GLsizei, GLboolean, Ptr{GLfloat}),
		u, 1, false, data)
	GetError()
end

