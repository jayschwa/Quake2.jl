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
typealias GLsizeiptr Ptr
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

################################################################################
#   Includes
################################################################################

include("buffer.jl")
include("program.jl")
include("shader.jl")
include("utils.jl")
include("vertexarray.jl")

end # module

