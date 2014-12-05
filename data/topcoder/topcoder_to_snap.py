#!/usr/bin/env python
#
# Python script to convert topcoder data set into snap format.
#
import snap
import sys

if (len(sys.argv) != 3):
    print "Program to convert topcoder network file (plain text) to snap edgelist format"
    print "Usage: %s input_file output_file" % sys.argv[0]
    print "Example: %s network network.snap.txt" % sys.argv[0]
    sys.exit(1)

input_filename = sys.argv[1]
output_filename = sys.argv[2]

num_nodes = 0
num_edges = 0
with open(input_filename, 'r') as input:
    # Parse the first line in the file: it's a list of the degree of each node,
    # in order.
    first_line = input.readline()
    first_line.rstrip()
    print "Processing first line in file to determine size of graph..."
    degrees = first_line.split()
    num_nodes = len(degrees)
    for node_deg in degrees:
        # The degree list data counts the node itself, which is wrong.
        node_deg_num = int(node_deg)
        num_edges += node_deg_num
    print "According to the header data: Num nodes: %s, num edges: %s" % (num_nodes, num_edges)

    num_edges = 42851237
    print "Actually, we know that the file header is wrong, the correct # edges is %s, overriding." % num_edges

    # Now, just build the graph.
    g1 = snap.TUNGraph.New(num_nodes, num_edges)

    # Define the nodes.
    for node_id in xrange(0, num_nodes):
        g1.AddNode(node_id)

    # Define the edges.
    node_id = 0
    while True:
        line = input.readline()
        if not line:
            break
        # Print a progress indicator.
        if (node_id % 100000 == 0):
            print "Processing node_id %s" % node_id
        assert node_id < num_nodes, "Node ID %s is not less than num nodes %s" % (node_id, num_nodes)
        line.rstrip()
        edges = line.split()
        for edge in edges:
            neighbor_id = int(edge)
            ret = g1.AddEdge(node_id, neighbor_id)
            assert ret == -1, "AddEdge() returned %s" % ret
        node_id += 1

    print "Graph construction complete. Final num nodes = %s, num edges = %s" % (g1.GetNodes(), g1.GetEdges())
    print "Saving edgelist to file: %s" % output_filename
    snap.SaveEdgeList(g1, output_filename, "Topcoder dataset in snap edgelist format")

sys.exit(0)
