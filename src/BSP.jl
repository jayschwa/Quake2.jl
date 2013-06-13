module BSP

importall ImmutableArrays
import Base.search

include("bsp/Mesh.jl")
include("bsp/Tree.jl")

export Bsp
type Bsp
	tree::Tree.Node
	entities::Vector{Dict{String,String}}
	vertices::Vector{Vector3{Float32}}
	faces::Vector{Mesh.Face}
	max_lights::Int
end

include("bsp/File.jl")

search(bsp::Bsp, pos::AbstractVector) = search(bsp.tree, pos)

end

