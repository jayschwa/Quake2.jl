function GenVertexArrays(count::Integer)
	a = Array(VertexArray, count)
	ccall( (:glGenVertexArrays, lib), Void, (GLsizei, Ptr{Buffer}), count, a)
	GetError()
	return a
end

function GenVertexArray()
	return GenVertexArrays(1)[1]
end

function BindVertexArray(va::VertexArray)
	ccall( (:glBindVertexArray, lib), Void, (VertexArray,), va)
	GetError() # TODO: Benchmark overhead
end

