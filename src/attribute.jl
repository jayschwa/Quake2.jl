function GetAttribLocation(prog::Program, name::String)
	ret = ccall( (:glGetAttribLocation, lib), Attribute,
		(Program, Ptr{GLchar}), prog, name)
	if ret < 0
		GetError()
		error("attribute not found")
	else
		return ret
	end
end

function VertexAttribPointer(attr::Attribute, size::Integer, type_::GLenum,
	normalize::Bool, stride::GLsizei, ptr::Ptr)

	ccall( (:glVertexAttribPointer, lib), Void
		(Attribute, GLint, GLenum, GLboolean, GLsizei, Ptr{GLvoid}),
		attr, size, type_, normalize, stride, ptr)
	GetError()
end

