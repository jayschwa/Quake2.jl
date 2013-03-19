function Uniform(prog::Program, name::String)
	ret = ccall( (:glGetUniformLocation, lib), GLint,
		(Program, Ptr{GLchar}), prog, bytestring(name))
	if ret < 0
		GetError()
		error("uniform not found")
	else
		return Uniform(ret)
	end
end

import Base.write

for (T,t) in ((Float32, "f"), (Int32, "i"), (Uint32, "ui"))
	@eval begin
		write(u::Uniform, vals::$T) =
			ccall(($(string("glUniform1", t)), lib), Void,
				(GLint, $T), u.location, vals)
		write(u::Uniform, vals::GL.GLSLType2{$T}) =
			ccall(($(string("glUniform2", t, "v")), lib), Void,
				(GLint, GLsizei, Ptr{GL.GLSLType2{$T}}), u.location, 1, &vals)
		write(u::Uniform, vals::GL.GLSLType3{$T}) =
			ccall(($(string("glUniform3", t, "v")), lib), Void,
				(GLint, GLsizei, Ptr{GL.GLSLType3{$T}}), u.location, 1, &vals)
		write(u::Uniform, vals::GL.GLSLType4{$T}) =
			ccall(($(string("glUniform4", t, "v")), lib), Void,
				(GLint, GLsizei, Ptr{GL.GLSLType4{$T}}), u.location, 1, &vals)
	end
end

function UniformMatrix4fv(u::Uniform, data::Array{Float32,2})
	ccall( (:glUniformMatrix4fv, lib), Void,
		(GLint, GLsizei, GLboolean, Ptr{GLfloat}),
		u.location, 1, false, data)
	GetError()
end

