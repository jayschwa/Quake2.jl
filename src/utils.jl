################################################################################
#   Utilities
################################################################################

# Error codes
const NO_ERROR          = 0
const INVALID_ENUM      = 0x0500
const INVALID_VALUE     = 0x0501
const INVALID_OPERATION = 0x0502
const OUT_OF_MEMORY     = 0x0505

function GetError()
	ret = ccall( (:glGetError, lib), GLenum, ())
	if ret != NO_ERROR
		error(ret)
	end
end

function GetString(name::Integer)
	ret = ccall( (:glGetString, lib), Ptr{GLubyte}, (GLenum,), name)
	bytestring(ret)
end

function GetStringi(name::Integer, index::Integer)
	ret = ccall( (:glGetStringi, lib), Ptr{GLubyte}, (GLenum, GLuint), name, index)
	bytestring(ret)
end

GetString(name::Integer, index::Integer) = GetStringi(name, index)

# String names
const VENDOR                   = 0x1F00
const RENDERER                 = 0x1F01
const VERSION                  = 0x1F02
const SHADING_LANGUAGE_VERSION = 0x8B8C
const EXTENSIONS               = 0x1F03

