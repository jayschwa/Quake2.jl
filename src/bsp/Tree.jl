module Tree

importall ImmutableArrays
import Mesh.Face
import Base:cmp,search

type Leaf
	faces::Vector{Face}
end

type Node
	front::Union(Node,Leaf)
	back::Union(Node,Leaf)
	normal::Vector3{Float32}
	distance::Float32
end

cmp(pos::Vector3, node::Node) = sign(dot(pos,node.normal)-node.distance)

function search(tree::Node, pos::Vector3)
	if cmp(pos, tree) < 0
		return search(tree.back, pos)
	else
		return search(tree.front, pos)
	end
end
search(leaf::Leaf, ::Vector3) = leaf

end

