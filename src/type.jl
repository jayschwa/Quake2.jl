typealias GLboolean  Bool
typealias GLbyte     Int8
typealias GLubyte    Uint8
typealias GLchar     Uint8
typealias GLshort    Int16
typealias GLushort   Uint16
typealias GLint      Int32
typealias GLuint     Uint32
typealias GLint64    Int64
typealias GLuint64   Uint64
typealias GLsizei    Uint32
typealias GLenum     Uint32
typealias GLintptr   Ptr
typealias GLsizeiptr Int
typealias GLfloat    Float32
typealias GLdouble   Float64
typealias GLvoid     Void

typealias Object      GLuint
typealias Buffer      Object
typealias Program     Object
typealias Shader      Object
typealias Texture     Object
typealias VertexArray Object

typealias Attribute GLint

immutable Uniform
	location::GLint
	Uniform(location) = new(convert(GLint, location))
end
+(u::Uniform, i::Integer) = Uniform(u.location+i)

import Base:cross,getindex,reshape,size

immutable GLSLVector2{T} <: AbstractVector{T}
	v1::T
	v2::T
	GLSLVector3(v1, v2) = new(convert(T, v1), convert(T, v2))
end
GLSLVector2{T}(v1::T, v2::T) = GLSLVector3{T}(v1, v2)

function getindex(x::GLSLVector2,i::Integer)
	if i == 1
		return x.v1
	elseif i == 2
		return x.v2
	else
		BoundsError()
	end
end
+(x::GLSLVector2, y::GLSLVector2) = GLSLVector2(x.v1+y.v1, x.v2+y.v2)
-(x::GLSLVector2) = GLSLVector2(-x.v1, -x.v2)
-(x::GLSLVector2, y::GLSLVector2) = GLSLVector2(x.v1-y.v1, x.v2-y.v2)
.*{T}(x::GLSLVector2{T}, y::Number) = GLSLVector2{T}(x.v1*y, x.v2*y)
./{T}(x::GLSLVector2{T}, y::Number) = GLSLVector2{T}(x.v1/y, x.v2/y)
reshape{T}(x::GLSLVector2{T}, ::Dims) = T[x.v1, x.v2]' #TODO: Is this correct?
size(::GLSLVector2) = (2,)

immutable GLSLVector3{T} <: AbstractVector{T}
	v1::T
	v2::T
	v3::T
	GLSLVector3(v1, v2, v3) = new(convert(T, v1), convert(T, v2), convert(T, v3))
end
GLSLVector3{T}(v1::T, v2::T, v3::T) = GLSLVector3{T}(v1, v2, v3)

function getindex(x::GLSLVector3,i::Integer)
	if i == 1
		return x.v1
	elseif i == 2
		return x.v2
	elseif i == 3
		return x.v3
	else
		BoundsError()
	end
end
+(x::GLSLVector3, y::GLSLVector3) = GLSLVector3(x.v1+y.v1, x.v2+y.v2, x.v3+y.v3)
-(x::GLSLVector3) = GLSLVector3(-x.v1, -x.v2, -x.v3)
-(x::GLSLVector3, y::GLSLVector3) = GLSLVector3(x.v1-y.v1, x.v2-y.v2, x.v3-y.v3)
.*{T}(x::GLSLVector3{T}, y::Number) = GLSLVector3{T}(x.v1*y, x.v2*y, x.v3*y)
.*(y::Number, x::GLSLVector3) = .*(x, y)
./{T}(x::GLSLVector3{T}, y::Number) = GLSLVector3{T}(x.v1/y, x.v2/y, x.v3/y)
cross(a::GLSLVector3, b::GLSLVector3) = GLSLVector3(a[2]*b[3]-a[3]*b[2], a[3]*b[1]-a[1]*b[3], a[1]*b[2]-a[2]*b[1])
reshape{T}(x::GLSLVector3{T}, ::Dims) = T[x.v1, x.v2, x.v3]'
size(::GLSLVector3) = (3,)

immutable GLSLVector4{T} <: AbstractVector{T}
	v1::T
	v2::T
	v3::T
	v4::T
	GLSLVector4(v1, v2, v3, v4) = new(convert(T, v1), convert(T, v2), convert(T, v3), convert(T, v4))
end
GLSLVector4{T}(v1::T, v2::T, v3::T, v4::T) = GLSLVector4{T}(v1, v2, v3, v4)

function getindex(x::GLSLVector4,i::Integer)
	if i == 1
		return x.v1
	elseif i == 2
		return x.v2
	elseif i == 3
		return x.v3
	elseif i == 4
		return x.v4
	else
		BoundsError()
	end
end
+(x::GLSLVector4, y::GLSLVector4) = GLSLVector4(x.v1+y.v1, x.v2+y.v2, x.v3+y.v3, x.v4+y.v4)
-(x::GLSLVector4) = GLSLVector4(-x.v1, -x.v2, -x.v3, -x.v4)
-(x::GLSLVector4, y::GLSLVector4) = GLSLVector4(x.v1-y.v1, x.v2-y.v2, x.v3-y.v3, x.v4-y.v4)
.*{T}(x::GLSLVector4{T}, y::Number) = GLSLVector4{T}(x.v1*y, x.v2*y, x.v3*y, x.v4*y)
./{T}(x::GLSLVector4{T}, y::Number) = GLSLVector4{T}(x.v1/y, x.v2/y, x.v3/y, x.v4/y)
reshape{T}(x::GLSLVector4{T}, ::Dims) = T[x.v1, x.v2, x.v3, x.v4]'
size(::GLSLVector4) = (4,)

typealias Vec2 GLSLVector2{Float32}
typealias Vec3 GLSLVector3{Float32}
typealias Vec4 GLSLVector4{Float32}

