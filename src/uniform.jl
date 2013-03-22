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
		# Write single vector
		write(u::Uniform, val::$T) =
			ccall(($(string("glUniform1", t)), lib), Void,
				(GLint, $T), u.location, val)
		write(u::Uniform, val::GL.GLSLVector2{$T}) =
			ccall(($(string("glUniform2", t, "v")), lib), Void,
				(GLint, GLsizei, Ptr{GL.GLSLVector2{$T}}), u.location, 1, &val)
		write(u::Uniform, val::GL.GLSLVector3{$T}) =
			ccall(($(string("glUniform3", t, "v")), lib), Void,
				(GLint, GLsizei, Ptr{GL.GLSLVector3{$T}}), u.location, 1, &val)
		write(u::Uniform, val::GL.GLSLVector4{$T}) =
			ccall(($(string("glUniform4", t, "v")), lib), Void,
				(GLint, GLsizei, Ptr{GL.GLSLVector4{$T}}), u.location, 1, &val)

		# Write matrix
		function write(u::Uniform, mat::Matrix{$T})
			sz = size(mat)
			if sz == (2,2)
				ccall(($(string("glUniformMatrix2", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (2,3)
				ccall(($(string("glUniformMatrix2x3", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (2,4)
				ccall(($(string("glUniformMatrix2x4", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (3,2)
				ccall(($(string("glUniformMatrix3x2", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (3,3)
				ccall(($(string("glUniformMatrix3", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (3,4)
				ccall(($(string("glUniformMatrix3x4", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (4,2)
				ccall(($(string("glUniformMatrix4x2", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (4,3)
				ccall(($(string("glUniformMatrix4x3", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			elseif sz == (4,4)
				ccall(($(string("glUniformMatrix4", t, "v")), lib), Void,
					(GLint, GLsizei, GLboolean, Ptr{$T}),
					u.location, 1, false, mat)
			else
				error("matrix size ", sz, " is not supported")
			end
		end
	end
end

write(u::Uniform, val::Bool) = write(u, convert(Uint32, val))

