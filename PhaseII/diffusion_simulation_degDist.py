#!/usr/bin/env python
"""
Diffusion simulation for Ebola spread.
Similar to NetworkSimulationForEbola.py except that this script only runs on
a single parameterization of T and outputs a single line to a file.
Based on diffusion_simulation.py for handling degree distribution for initial node 
"""
from __future__ import division     # So division returns a float.
from collections import deque       # Linked list impl.

import numpy as np
import os
import random
import snap
import sys
import time

TRANSMISSIBILITY = 0.1243

# Output a timestamped log line with the given string to stderr.
def log(str):
    timestamp = time.asctime()
    print >> sys.stderr, "[ %s ] %s" % (timestamp, str)

def runSimulation(graph, nodeDeg, iterations):
    log("Running simulation with params: nodeDeg=%s, iterations=%s ..." % (nodeDeg, iterations))
    totalInfected = 0
    nodeIdSet = set()
    InDegV = snap.TIntPrV()
    snap.GetNodeInDegV(graph,InDegV)
    for item in InDegV:
        currNodeDeg = item.GetVal2()
        if currNodeDeg >= nodeDeg:
            nodeIdSet.add(item.GetVal1())
    for iteration in xrange(0, iterations):
        log("Running iteration %s ..." % iteration)

        infected = set()            # All infected patients.
        infectedQueue = deque()     # Infected patients we have not "processed" yet.

        # Find and infect patient zero.
        if len(nodeIdSet) == 0:
            return 0
        else:
            patientZeroId = random.sample(nodeIdSet,1) # choose patient zero
            #print patientZeroId[0]
            infected.add(patientZeroId[0])
            infectedQueue.append(patientZeroId[0])
        # Run through the "infected" queue in FIFO order until all the
        # patients have had a turn.
        while infectedQueue:
            nodeId = infectedQueue.popleft()
            node = graph.GetNI(nodeId)
            numNeighbors = node.GetOutDeg()
            for nbrIndex in xrange(0, numNeighbors):
                nbrId = node.GetNbrNId(nbrIndex)
                if nbrId not in infected:
                    if random.random() < TRANSMISSIBILITY:
                        # We have infected them.
                        infected.add(nbrId)
                        infectedQueue.append(nbrId)
        totalInfected += len(infected)

    avgInfected = totalInfected / iterations
    infectedFraction = avgInfected / graph.GetNodes()
    return infectedFraction

def main():
    # Don't buffer output.
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
    sys.stderr = os.fdopen(sys.stderr.fileno(), 'w', 0)

    # Parse command-line arguments.
    if len(sys.argv) != 5:
        print >> sys.stderr, "Usage: %s inputFile nodeDeg iterations outputFile" % sys.argv[0]
        print >> sys.stderr, "Example: %s network.snap.txt 1100 100 infected.out" % sys.argv[0]
        sys.exit(1)
    inputFile           = sys.argv[1]
    nodeDeg             = float(sys.argv[2])
    iterations          = int(sys.argv[3])
    outputFile          = sys.argv[4]

    # Print blank line to stderr at the beginning of the output to make the GNU
    # parallel "ETA" output more readable.
    print >> sys.stderr, ""

    # Load edgelist.
    log("Loading graph from file %s ..." % inputFile)
    graph = snap.LoadEdgeList(snap.PUNGraph, inputFile, 0, 1)
    log("Graph loaded. Number of nodes: %s, number of edges: %s" % (graph.GetNodes(), graph.GetEdges()))

    # Open the output file early so we quickly fail if there is a permissions problem.
    f = open(outputFile, 'w')

    # Run the simulation.
    infectedFraction = runSimulation(graph, nodeDeg, iterations)

    # Output the results to the output file.
    log("Writing output to file: %s" % outputFile)
    print >> f, "# inputFile\tT\titerations\tinfectedFraction"  # Write a header line which we will drop later.
    print >> f, "%s\t%s\t%s\t%s" % (inputFile, nodeDeg, iterations, infectedFraction)
    f.close()

    sys.exit(0)

if __name__ == '__main__':
    main()
