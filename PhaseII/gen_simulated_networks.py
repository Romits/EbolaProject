#!/usr/bin/env python
"""
Generate simulated networks of the same size as the social network data.
"""
from __future__ import division     # So division returns a float.
from collections import deque       # Linked list impl.

import snap
import matplotlib.pyplot as plt
import random
import numpy as np
import os
import sys

def main():
    RANDOM_SEED = 23

    SYNTHETIC_NW_NODES = 4846609        # How many nodes in the fake networks.
    SYNTHETIC_NW_EDGES = 42851237       # How many nodes in the fake networks.
    SYNTHETIC_NW_AVG_DEGREE = int(SYNTHETIC_NW_EDGES / SYNTHETIC_NW_NODES)

    random.seed(RANDOM_SEED)

    print "Generating preferential attachment graph..."
    tRnd = snap.TRnd()
    tRnd.PutSeed(RANDOM_SEED) # Re-seed every time.
    PAGraph = snap.GenPrefAttach(SYNTHETIC_NW_NODES, SYNTHETIC_NW_AVG_DEGREE, tRnd)
    filename = 'PrefAttachSynthetic-4.8M.txt'
    print "Saving edge list to file: %s" % filename
    snap.SaveEdgeList(PAGraph, filename, 'Synthetic preferential attachment graph')

    print "Generating random graph..."
    tRnd.PutSeed(RANDOM_SEED) # Re-seed every time.
    RndGraph = snap.GenRndGnm(snap.PUNGraph, SYNTHETIC_NW_NODES, SYNTHETIC_NW_EDGES, False, tRnd)
    filename = 'GnmRandomGraph-4.8M.txt'
    print "Saving edge list to file: %s" % filename
    snap.SaveEdgeList(RndGraph, filename, 'Random Gnm graph')

    print "Generating small world graph..."
    tRnd.PutSeed(RANDOM_SEED) # Re-seed every time.
    SWGraph = snap.GenSmallWorld(SYNTHETIC_NW_NODES, SYNTHETIC_NW_AVG_DEGREE, 0.1, tRnd)
    filename = 'SmallWorldGraph-4.8M.txt'
    print "Saving edge list to file: %s" % filename
    snap.SaveEdgeList(RndGraph, filename, 'Small world graph with rewire prob=0.1')

    print "Done"

    sys.exit(0)

if __name__ == '__main__':
    main()
