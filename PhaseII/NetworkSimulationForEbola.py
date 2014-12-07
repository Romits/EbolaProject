#!/usr/bin/env python
"""
Code for Simulating Ebola Data on various
Network models to compare the spread of the
Epidemic

"""
from __future__ import division     # So division returns a float.
from collections import deque       # Linked list impl.

import snap
import matplotlib.pyplot as plt
import random
import numpy as np
import os
import sys

def loadGraphPrintStats(inputFile, graphType):
    outGraph = snap.LoadEdgeList(snap.PUNGraph, inputFile, 0, 1)
    nodeCount = snap.CntNonZNodes(outGraph)
    edgeCount = snap.CntUniqUndirEdges(outGraph)
    avgDeg = float(edgeCount)/nodeCount
    print "Average Degree for %s graph is %f" % (graphType, avgDeg)
    return outGraph

def runSimulations(graph, T, noOfIters):
    avgInfectedFractionPerT0 = list()
    for T0 in T:
        print "Running T0 = %s" % T0
        totalInfected = 0
        for simulationIter in xrange(0, noOfIters):
            print "Simulation iter: %s" % simulationIter
            infected = set()            # All infected patients.
            infectedQueue = deque()     # Infected patients we have not "processed" yet.

            # Find and infect patient zero.
            patientZeroId = graph.GetRndNId() # choose patient zero
            infected.add(patientZeroId)
            infectedQueue.append(patientZeroId)

            # Run through the "infected" queue in FIFO order until all the
            # patients have had a turn.
            while infectedQueue:
                nodeId = infectedQueue.popleft()
                node = graph.GetNI(nodeId)
                numNeighbors = node.GetOutDeg()
                for nbrIndex in xrange(0, numNeighbors):
                    nbrId = node.GetNbrNId(nbrIndex)
                    if nbrId not in infected:
                        if random.random() < T0:
                            # We have infected them.
                            infected.add(nbrId)
                            infectedQueue.append(nbrId)
            totalInfected += len(infected)
        avgInfected = totalInfected / noOfIters
        avgInfectedFractionPerT0.append(avgInfected / graph.GetNodes())
    return avgInfectedFractionPerT0

# Allow for plotting a single network for debugging.
def plotOne(realResult, T):
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.set_title("Ebola Epidemic West Africa-2014")
    X = T
    YR = np.array(realResult)
    line, = ax.plot(X,YR,'b-o',color='blue',label='Real Network', lw=2)
    ax.set_xlabel('Transmissiblity')
    ax.set_ylabel('Fraction of Network Infected')
    ax.set_xlim([0.00,0.22])
    ax.legend(loc=2)
    ax.axvline(x=0.1751, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    ax.text(0.1751, 0.16, 'Guinea')
    ax.axvline(x=0.0001, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    ax.text(0.0001, 0.16, 'Liberia')
    ax.axvline(x=0.1897, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    ax.text(0.1897, 0.16, 'Sierra Leone')
    plt.savefig('Ebola-Transmissiblity-Size-OneGuy')

# Plot 3 networks on the same graph.
def plotData(realResult, randomResult, swResult, T):
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.set_title("Ebola Epidemic West Africa-2014")
    X = T
    YR = np.array(realResult)
    YRnd = np.array(randomResult)
    YSw = np.array(swResult)
    line, = ax.plot(X,YR,'b-o',color='blue',label='Real Network', lw=2)
    line, = ax.plot(X,YRnd,'g-o',color='green',label='Random Network', lw=2)
    line, = plt.plot(X,YSw,'r-o',color='red',label='SmallWorld Network', lw=2)
    ax.set_xlabel('Transmissiblity')
    ax.set_ylabel('Fraction of Network Infected')
    ax.set_xlim([0.00,0.22])
    ax.legend(loc=2)
    ax.axvline(x=0.1751, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    ax.text(0.1751, 0.16, 'Guinea')
    ax.axvline(x=0.0001, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    ax.text(0.0001, 0.16, 'Liberia')
    ax.axvline(x=0.1897, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    ax.text(0.1897, 0.16, 'Sierra Leone')
    plt.savefig('Ebola-Transmissiblity-Size')

def main():
    RANDOM_SEED = 23
    SIMULATION_ITERS_PER_MODEL = 10     # How many simulations we do per model.
    SYNTHETIC_NW_NODES = 10000          # How many nodes in the fake networks.
    SYNTHETIC_NW_AVG_DEGREE = 20        # Avg degree for the fake networks.

    random.seed(RANDOM_SEED)

    # Don't buffer stdout.
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)

    """
    # Test on large (4M node) real network for one iteration and one value of T.
    T = [0.13]
    print "Running on real world network..."
    inputFile = "network.snap.txt"
    print "Loading graph..."
    realGraph = snap.LoadEdgeList(snap.PUNGraph, inputFile, 0, 1)
    print "Running simulation..."
    realResult = runSimulations(realGraph, T, 1)
    print "Plotting..."
    plotOne(realResult, T)
    print "Simulation complete"
    sys.exit(0)
    """

    T = np.linspace(0.000, 0.2500, 10)
    print T

    #PAGraph = loadGraphPrintStats('SamplePAGraph.txt','Preferential Attachment')
    tRnd = snap.TRnd()
    tRnd.PutSeed(RANDOM_SEED) # Re-seed every time.
    PAGraph = snap.GenPrefAttach(SYNTHETIC_NW_NODES, SYNTHETIC_NW_AVG_DEGREE, tRnd)
    resultListRN = runSimulations(PAGraph, T, SIMULATION_ITERS_PER_MODEL)
    print resultListRN

    #RndGraph = loadGraphPrintStats('SampleRndGraph.txt','Random Network')
    tRnd.PutSeed(RANDOM_SEED) # Re-seed every time.
    RndGraph = snap.GenRndGnm(snap.PUNGraph, SYNTHETIC_NW_NODES, SYNTHETIC_NW_NODES * SYNTHETIC_NW_AVG_DEGREE, False, tRnd)
    resultListRnd = runSimulations(RndGraph, T, SIMULATION_ITERS_PER_MODEL)
    print resultListRnd

    #SWGraph = loadGraphPrintStats('SampleSWGraph.txt','SmallWorld Network')
    tRnd.PutSeed(RANDOM_SEED) # Re-seed every time.
    SWGraph = snap.GenSmallWorld(SYNTHETIC_NW_NODES, SYNTHETIC_NW_AVG_DEGREE, 0.15, tRnd)
    resultListSW = runSimulations(SWGraph, T, SIMULATION_ITERS_PER_MODEL)
    print resultListSW

    plotData(resultListRN, resultListRnd, resultListSW, T)

if __name__ == '__main__':
    main()
