function CreateProgram()
	ret = ccall( (:glCreateProgram, lib), Program, ())
	if ret == 0
		GetError()
		error("Program creation failed")
	end
	return ret
end

function AttachShader(p::Program, s::Shader)
	ccall( (:glAttachShader, lib), Void, (Program, Shader), p, s)
	GetError()
end

function LinkProgram(p::Program)
	ccall( (:glLinkProgram, lib), Void, (Program,), p)
	if !GetProgram(p, LINK_STATUS)
		error(GetProgramInfoLog(s))
	end
end

function UseProgram(p::Program)
	ccall( (:glUseProgram, lib), Void, (Program,), p)
	GetError() # TODO: Benchmark overhead
end

const LINK_STATUS = 0x8B82

function GetProgram(p::Program, param::Integer)
	ret = GLint[-1]
	ccall( (:glGetProgramiv, lib), Void,
		(Program, GLenum, Ptr{GLint}), p, param, ret)
	ret = ret[1]
	if ret == -1
		GetError()
		error("no output")
	elseif contains((LINK_STATUS, DELETE_STATUS), param)
		return ret == 1
	else
		return ret
	end
end

function GetProgramInfoLog(p::Program)
	size = GetProgram(s, INFO_LOG_LENGTH)
	buf = Array(GLchar, size)
	ccall( (:glGetProgramInfoLog, lib), Void,
		(Program, GLsizei, Ptr{GLsizei}, Ptr{GLchar}),
		p, size, &size, buf)
	return bytestring(buf)
end

