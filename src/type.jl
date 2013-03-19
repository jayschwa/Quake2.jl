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
end

import Base:cross,getindex,reshape,size

immutable GLSLType2{T} <: AbstractVector{T}
	v1::T
	v2::T
	GLSLType3(v1, v2) = new(convert(T, v1), convert(T, v2))
end
GLSLType2{T}(v1::T, v2::T) = GLSLType3{T}(v1, v2)

function getindex(x::GLSLType2,i::Integer)
	if i == 1
		return x.v1
	elseif i == 2
		return x.v2
	else
		BoundsError()
	end
end
+(x::GLSLType2, y::GLSLType2) = GLSLType2(x.v1+y.v1, x.v2+y.v2)
-(x::GLSLType2) = GLSLType2(-x.v1, -x.v2)
-(x::GLSLType2, y::GLSLType2) = GLSLType2(x.v1-y.v1, x.v2-y.v2)
.*{T}(x::GLSLType2{T}, y::Number) = GLSLType2{T}(x.v1*y, x.v2*y)
./{T}(x::GLSLType2{T}, y::Number) = GLSLType2{T}(x.v1/y, x.v2/y)
reshape{T}(x::GLSLType2{T}, ::Dims) = T[x.v1, x.v2]'
size(::GLSLType2) = (2,)

immutable GLSLType3{T} <: AbstractVector{T}
	v1::T
	v2::T
	v3::T
	GLSLType3(v1, v2, v3) = new(convert(T, v1), convert(T, v2), convert(T, v3))
end
GLSLType3{T}(v1::T, v2::T, v3::T) = GLSLType3{T}(v1, v2, v3)

function getindex(x::GLSLType3,i::Integer)
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
+(x::GLSLType3, y::GLSLType3) = GLSLType3(x.v1+y.v1, x.v2+y.v2, x.v3+y.v3)
-(x::GLSLType3) = GLSLType3(-x.v1, -x.v2, -x.v3)
-(x::GLSLType3, y::GLSLType3) = GLSLType3(x.v1-y.v1, x.v2-y.v2, x.v3-y.v3)
.*{T}(x::GLSLType3{T}, y::Number) = GLSLType3{T}(x.v1*y, x.v2*y, x.v3*y)
.*(y::Number, x::GLSLType3) = .*(x, y)
./{T}(x::GLSLType3{T}, y::Number) = GLSLType3{T}(x.v1/y, x.v2/y, x.v3/y)
cross(a::GLSLType3, b::GLSLType3) = GLSLType3(a[2]*b[3]-a[3]*b[2], a[3]*b[1]-a[1]*b[3], a[1]*b[2]-a[2]*b[1])
reshape{T}(x::GLSLType3{T}, ::Dims) = T[x.v1, x.v2, x.v3]'
size(::GLSLType3) = (3,)

immutable GLSLType4{T} <: AbstractVector{T}
	v1::T
	v2::T
	v3::T
	v4::T
	GLSLType4(v1, v2, v3, v4) = new(convert(T, v1), convert(T, v2), convert(T, v3), convert(T, v4))
end
GLSLType4{T}(v1::T, v2::T, v3::T, v4::T) = GLSLType4{T}(v1, v2, v3, v4)

function getindex(x::GLSLType4,i::Integer)
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
+(x::GLSLType4, y::GLSLType4) = GLSLType4(x.v1+y.v1, x.v2+y.v2, x.v3+y.v3, x.v4+y.v4)
-(x::GLSLType4) = GLSLType4(-x.v1, -x.v2, -x.v3, -x.v4)
-(x::GLSLType4, y::GLSLType4) = GLSLType4(x.v1-y.v1, x.v2-y.v2, x.v3-y.v3, x.v4-y.v4)
.*{T}(x::GLSLType4{T}, y::Number) = GLSLType4{T}(x.v1*y, x.v2*y, x.v3*y, x.v4*y)
./{T}(x::GLSLType4{T}, y::Number) = GLSLType4{T}(x.v1/y, x.v2/y, x.v3/y, x.v4/y)
reshape{T}(x::GLSLType4{T}, ::Dims) = T[x.v1, x.v2, x.v3, x.v4]'
size(::GLSLType4) = (4,)

typealias Vec2 GLSLType2{Float32}
typealias Vec3 GLSLType3{Float32}
typealias Vec4 GLSLType4{Float32}

