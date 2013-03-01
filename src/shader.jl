const FRAGMENT_SHADER = 0x8B30
const VERTEX_SHADER   = 0x8B31

function CreateShader(type_::Integer)
	ret = ccall( (:glCreateShader, lib), Shader, (GLenum,), type_)
	if ret == 0
		GetError()
		error("shader creation failed")
	end
	return ret
end

function ShaderSource(s::Shader, src::String)
	ccall( (:glShaderSource, lib), Void,
		(GLuint, GLsizei, Ptr{Ptr{GLchar}}, Ptr{GLint}),
		s, 1, [bytestring(src)], [length(src)])
end

function CompileShader(s::Shader)
	ccall( (:glCompileShader, lib), Void, (Shader,), s)
	if !GetShader(s, COMPILE_STATUS)
		error(GetShaderInfoLog(s))
	end
end

const COMPILE_STATUS = 0x8B81

function GetShader(s::Shader, param::Integer)
	ret = GLint[-1]
	ccall( (:glGetShaderiv, lib), Void,
		(Shader, GLenum, Ptr{GLint}), s, param, ret)
	ret = ret[1]
	if ret == -1
		GetError()
		error("no output")
	elseif contains((COMPILE_STATUS, DELETE_STATUS), param)
		return ret == 1
	else
		return ret
	end
end

function GetShaderInfoLog(s::Shader)
	size = GetShader(s, INFO_LOG_LENGTH)
	buf = Array(GLchar, size)
	ccall( (:glGetShaderInfoLog, lib), Void,
		(Shader, GLsizei, Ptr{GLsizei}, Ptr{GLchar}),
		s, size, &size, buf)
	return bytestring(buf)
end

