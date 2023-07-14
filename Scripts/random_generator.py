import networkx as nx
import random
import sys

# Create a new graph
graph = nx.Graph()

# Define the number of nodes and edges you want in your graph
num_nodes = 100000  # Adjust as per your requirement
num_edges = 500000  # Adjust as per your requirement

def progress(count, total):
    i = int(count/total * 100)
    segments = int(i/5)
    sys.stdout.write('\r')
    # the exact output you're looking for:
    sys.stdout.write("[%-20s] %d%%" % ('='*segments, i))
    sys.stdout.flush()

# Add nodes to the graph
print("Adding nodes to the graph...")
for i in range(num_nodes):
    graph.add_node(i)
    progress(i + 1, num_nodes)

# Add random edges to the graph
print("\n\nAdding edges to the graph...")
for i in range(num_edges):
    source = random.randint(0, num_nodes - 1)
    target = random.randint(0, num_nodes - 1)
    graph.add_edge(source, target)
    progress(i + 1, num_edges)



# Save the graph as a GraphML file
nx.write_graphml(graph, "random_graph.graphml")