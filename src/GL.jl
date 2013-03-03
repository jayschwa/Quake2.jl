module GL

const lib = "libGL"

################################################################################
#   Types
################################################################################

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
typealias VertexArray Object

typealias Attribute GLint
typealias Uniform   GLint

################################################################################
#   Shared Enums
################################################################################

# Program and Shader GetInfoLog()
const DELETE_STATUS   = 0x8B80
const INFO_LOG_LENGTH = 0x8B84

# Data Types
const BYTE           = 0x1400
const UNSIGNED_BYTE  = 0x1401
const SHORT          = 0x1402
const UNSIGNED_SHORT = 0x1403
const INT            = 0x1404
const UNSIGNED_INT   = 0x1405
const FLOAT          = 0x1406
const DOUBLE         = 0x140A

const GLtype = [
	Int8    => BYTE,
	Uint8   => UNSIGNED_BYTE,
	Int16   => SHORT,
	Uint16  => UNSIGNED_SHORT,
	Int32   => INT,
	Uint32  => UNSIGNED_INT,
	Float32 => FLOAT,
	Float64 => DOUBLE
]

################################################################################
#   Includes
################################################################################

include("attribute.jl")
include("buffer.jl")
include("draw.jl")
include("program.jl")
include("shader.jl")
include("uniform.jl")
include("utils.jl")
include("vertexarray.jl")

end # module

