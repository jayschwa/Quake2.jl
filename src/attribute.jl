function GetAttribLocation(prog::Program, name::String)
	ret = ccall( (:glGetAttribLocation, lib), Attribute,
		(Program, Ptr{GLchar}), prog, bytestring(name))
	if ret < 0
		GetError()
		error("attribute not found")
	else
		return ret
	end
end

function EnableVertexAttribArray(attr::Attribute)
	ccall( (:glEnableVertexAttribArray, lib), Void, (Attribute,), attr)
end

function VertexAttribPointer(attr::Attribute, size::Integer, type_::Integer,
	normalize::Bool, stride::Integer, ptr::Integer)

	ccall( (:glVertexAttribPointer, lib), Void,
		(Attribute, GLint, GLenum, GLboolean, GLsizei, Ptr{GLvoid}),
		attr, size, type_, normalize, stride, ptr)
	GetError()
end

