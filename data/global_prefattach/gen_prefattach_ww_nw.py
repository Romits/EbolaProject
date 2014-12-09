#!/usr/bin/env python
##########################################################
from __future__ import division
from sortedcontainers import SortedSet
import re
import snap
import sys

pop_file = 'cia_wfb_population.tsv'

# From our real-world network.
# 'SocialNetwork-4.8M.txt'
real_nodes = 4846609
real_edges = 42851237
avg_deg = int(real_edges / real_nodes)


Rnd = snap.TRnd()

# Factor by which we scaled down the world wide network
cheese_factor = -1

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
            cheese_factor = population / real_nodes
            print "Cheese factor: %s" % cheese_factor

        desired_nodes_for_country = int(population / cheese_factor)

        # Now we have scaled down the network to the size we want it for the country.
        base_out_file_name = "%03d-%s-%s-%d" % (rank, country_key, "PrefAttach", desired_nodes_for_country)
        meta_out_file_name = "%s.meta" % base_out_file_name
        graph_out_file_name = "%s.graph" % base_out_file_name

        print "Generating network of size %d for %s..." % (desired_nodes_for_country, country)
        graph = snap.GenPrefAttach(desired_nodes_for_country, avg_deg, Rnd)
        snap.SaveEdgeList(graph, graph_out_file_name)

        mfile = open(meta_out_file_name, "w")
        metadata_header = "# Rank: %s; Country: %s; Start: %s; Size: %s" % (rank, country, num_nodes_outputted, desired_nodes_for_country)
        print metadata_header
        print >> mfile, metadata_header
        mfile.close()

        num_nodes_outputted += desired_nodes_for_country
