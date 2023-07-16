import networkx as nx

def add_edge(graph, node1, node2):
    if node1 not in graph:
        graph.add_node(node1)
    if node2 not in graph:
        graph.add_node(node2)
    graph.add_edge(node1, node2)

def generate_fractal_graph(depth):
    graph = nx.DiGraph()
    generate_fractal_edges(graph, 0, 0, depth)
    return graph

def generate_fractal_edges(graph, x, y, depth):
    if depth == 0:
        return
    nx, ny = x + 1, y + 1
    add_edge(graph, (x, y), (nx, y))
    add_edge(graph, (nx, y), (nx, ny))
    add_edge(graph, (nx, ny), (x, ny))
    add_edge(graph, (x, ny), (x, y))
    generate_fractal_edges(graph, x + 0.5, y + 0.5, depth - 1)

G = generate_fractal_graph(10)

nx.draw(G, with_labels=True)

nx.write_graphml(G, "fractal_graph.graphml")
