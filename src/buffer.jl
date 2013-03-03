function GenBuffers(count::Integer)
	a = Array(Buffer, count)
	ccall( (:glGenBuffers, lib), Void, (GLsizei, Ptr{Buffer}), count, a)
	return a
end

function GenBuffer()
	return GenBuffers(1)[1]
end

# Buffer targets
const ARRAY_BUFFER              = 0x8892
const ATOMIC_COUNTER_BUFFER     = 0x92C0
const COPY_READ_BUFFER          = 0x8F36
const COPY_WRITE_BUFFER         = 0x8F37
const DRAW_INDIRECT_BUFFER      = 0x8F3F
const DISPATCH_INDIRECT_BUFFER  = 0x90EE
const ELEMENT_ARRAY_BUFFER      = 0x8893
const PIXEL_PACK_BUFFER         = 0x88EB
const PIXEL_UNPACK_BUFFER       = 0x88EC
const SHADER_STORAGE_BUFFER     = 0x90D2
const TEXTURE_BUFFER            = 0x8C2A
const TRANSFORM_FEEDBACK_BUFFER = 0x8C8E
const UNIFORM_BUFFER            = 0x8A11

function BindBuffer(target::Integer, buf::Integer)
	ccall( (:glBindBuffer, lib), Void, (GLenum, Buffer), target, buf)
	GetError() # TODO: Benchmark overhead
end

# Buffer usage
const STREAM_DRAW  = 0x88E0
const STREAM_READ  = 0x88E1
const STREAM_COPY  = 0x88E2
const STATIC_DRAW  = 0x88E4
const STATIC_READ  = 0x88E5
const STATIC_COPY  = 0x88E6
const DYNAMIC_DRAW = 0x88E8
const DYNAMIC_READ = 0x88E9
const DYNAMIC_COPY = 0x88EA

function BufferData(target::Integer, size::Integer, data::Ptr, usage::Integer)
	ccall( (:glBufferData, lib), Void,
		(GLenum, GLsizeiptr, Ptr{GLvoid}, GLenum),
		target, size, data, usage)
	GetError()
end

BufferData{T}(target::Integer, data::Array{T}, usage::Integer) =
	BufferData(target, length(data) * sizeof(T), convert(Ptr{T}, data), usage)

