function GenTextures(num::Integer)
	textures = Array(Texture, num)
	ccall( (:glGenTextures, lib), Void, (GLsizei, Ptr{Texture}), num, textures)
	return textures
end

GenTexture() = GenTextures(1)[1]

function BindTexture(target::Integer, texture::Integer)
	ccall( (:glBindTexture, lib), Void, (GLenum, Texture), target, texture)
end

# BindTexture targets
const TEXTURE_1D         = 0x0DE0
const TEXTURE_2D         = 0x0DE1
const TEXTURE_3D         = 0x806F

function TexImage2D{T}(target::Integer, intformat::Integer, width::Integer,
	height::Integer, format::Integer, data::Array{T})

	ccall( (:glTexImage2D, lib), Void,
		(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, Ptr{GLvoid}),
		target, 0, intformat, width, height, 0, format, GLtype[T], data)
	GetError()
end

# Pixel formats
const RGB  = 0x1907
const RGBA = 0x1908
const RGB8 = 0x8051

function TexParameteri(target::Integer, param::Integer, value::Integer)
	ccall( (:glTexParameteri, lib), Void, (GLenum, GLenum, GLint),
		target, param, value)
end

# Texture parameters
const TEXTURE_DEPTH      = 0x8071
const TEXTURE_MAG_FILTER = 0x2800
const TEXTURE_MIN_FILTER = 0x2801
const TEXTURE_WRAP_S     = 0x2802
const TEXTURE_WRAP_T     = 0x2803
const TEXTURE_WRAP_R     = 0x8072

const NEAREST                = 0x2600
const LINEAR                 = 0x2601
const NEAREST_MIPMAP_NEAREST = 0x2700
const LINEAR_MIPMAP_NEAREST  = 0x2701
const NEAREST_MIPMAP_LINEAR  = 0x2702
const LINEAR_MIPMAP_LINEAR   = 0x2703
const REPEAT                 = 0x2901
const CLAMP_TO_EDGE          = 0x812F

function ActiveTexture(texture::Integer)
	ccall( (:glActiveTexture, lib), Void, (GLenum,), texture)
end

const TEXTURE0  = 0x84C0
const TEXTURE1  = 0x84C1
const TEXTURE2  = 0x84C2
const TEXTURE3  = 0x84C3
const TEXTURE4  = 0x84C4
const TEXTURE5  = 0x84C5
const TEXTURE6  = 0x84C6
const TEXTURE7  = 0x84C7
const TEXTURE8  = 0x84C8
const TEXTURE9  = 0x84C9
const TEXTURE10 = 0x84CA
const TEXTURE11 = 0x84CB
const TEXTURE12 = 0x84CC
const TEXTURE13 = 0x84CD
const TEXTURE14 = 0x84CE
const TEXTURE15 = 0x84CF
const TEXTURE16 = 0x84D0
const TEXTURE17 = 0x84D1
const TEXTURE18 = 0x84D2
const TEXTURE19 = 0x84D3
const TEXTURE20 = 0x84D4
const TEXTURE21 = 0x84D5
const TEXTURE22 = 0x84D6
const TEXTURE23 = 0x84D7
const TEXTURE24 = 0x84D8
const TEXTURE25 = 0x84D9
const TEXTURE26 = 0x84DA
const TEXTURE27 = 0x84DB
const TEXTURE28 = 0x84DC
const TEXTURE29 = 0x84DD
const TEXTURE30 = 0x84DE
const TEXTURE31 = 0x84DF

