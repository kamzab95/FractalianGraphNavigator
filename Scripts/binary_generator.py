import networkx as nx

# Binary tree node
class Node:
    def __init__(self, id):
        self.id = id
        self.left = None
        self.right = None

# Function to create a binary tree of depth 'depth'
def create_tree(depth, id=1):
    if depth < 0:
        return None
    node = Node(id)
    node.left = create_tree(depth - 1, id * 2)
    node.right = create_tree(depth - 1, id * 2 + 1)
    return node

# Function to convert the binary tree to a graph (NetworkX DiGraph)
def tree_to_graph(root):
    G = nx.DiGraph()
    _tree_to_graph_rec(root, G)
    return G

# Recursive function used by tree_to_graph()
def _tree_to_graph_rec(node, G):
    if node is None:
        return
    if node.left is not None:
        G.add_edge(node.id, node.left.id)
        _tree_to_graph_rec(node.left, G)
    if node.right is not None:
        G.add_edge(node.id, node.right.id)
        _tree_to_graph_rec(node.right, G)

# Creating a binary tree of depth n
n = 12
binary_tree = create_tree(n)

# Converting the binary tree to a graph
G = tree_to_graph(binary_tree)

# Saving the graph to a .graphml file
nx.write_graphml(G, 'binary_graph.graphml')
