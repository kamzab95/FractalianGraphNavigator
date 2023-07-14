import networkx as nx

def add_edges(graph, node, depth, max_depth, edge_counter):
    if depth < max_depth:
        node_left = f"n{2*node+1}"
        node_right = f"n{2*node+2}"
        edge_left = f"e{2*edge_counter}"
        edge_right = f"e{2*edge_counter+1}"
        graph.add_edge(f"n{node}", node_left, id=edge_left)
        graph.add_edge(f"n{node}", node_right, id=edge_right)
        edge_counter += 1
        add_edges(graph, 2*node+1, depth + 1, max_depth, edge_counter)
        add_edges(graph, 2*node+2, depth + 1, max_depth, edge_counter)

def generate_fractal_graph(max_depth):
    graph = nx.MultiDiGraph()
    root_node = 0
    add_edges(graph, root_node, 0, max_depth, 0)
    return graph

# Specify the depth of the binary tree
depth = 50000

# Generate the fractal graph and write to a GraphML file
fractal_graph = generate_fractal_graph(depth)
nx.write_graphml(fractal_graph, "fractal_graph.graphml")