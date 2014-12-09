#!/usr/bin/env python
##########################################################
from __future__ import division
from sortedcontainers import SortedSet
import re
import snap
import sys

graph_file = 'SocialNetwork-4.8M.txt'
pop_file = 'cia_wfb_population.tsv'

graph = snap.LoadEdgeList(snap.PUNGraph, graph_file, 0, 1)
orig_num_nodes = graph.GetNodes()
cur_num_nodes = orig_num_nodes

# Factor by which we scaled down the world wide network
cheese_factor = -1

deleted_nodes = SortedSet()
num_nodes_outputted = 0

with open(pop_file) as f:
    while True:
        line = f.readline()
        if not line:
            # EOF.
            break
        line = line.strip()

        # Skip comment lines.
        if line.startswith("#"):
            continue

        (rank_str, country, population_str) = line.split("\t")
        population = int(re.sub('[^0-9]', '', population_str))
        country_key = re.sub(' ', '_', country)
        rank = int(rank_str)

        # Top pop gets the whole graph.
        if rank == 1:
            cheese_factor = population / orig_num_nodes
            print "Cheese factor: %s" % cheese_factor

        desired_nodes_for_country = population / cheese_factor
        while cur_num_nodes > desired_nodes_for_country:
            nid_to_delete = graph.GetRndNId()
            graph.DelNode(nid_to_delete)
            deleted_nodes.add(nid_to_delete)
            cur_num_nodes -= 1

        # Now we have scaled down the network to the size we want it for the country.
        base_out_file_name = "%03d-%s-%s-%d" % (rank, country_key, graph_file, cur_num_nodes)
        meta_out_file_name = "%s.meta" % base_out_file_name
        graph_out_file_name = "%s.graph" % base_out_file_name
        snap.SaveEdgeList(graph, graph_out_file_name)
        mfile = open(meta_out_file_name, "w")
        metadata_header = "# Rank: %s; Country: %s; Start: %s; Size: %s" % (rank, country, num_nodes_outputted, cur_num_nodes)
        print metadata_header
        print >> mfile, metadata_header
        for nid in deleted_nodes:
            print >> mfile, nid
        mfile.close()

        num_nodes_outputted += cur_num_nodes
