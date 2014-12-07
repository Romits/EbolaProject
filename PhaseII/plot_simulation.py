#!/usr/bin/env python
"""
Plot concatenation of outputs of diffusion_simulation.py

The file format looks like this:

# inputFile	T	iters	infectedFraction
network.snap	0.0	2	2.06329827721e-07
network.snap	0.05	2	0.245230943945
network.snap	0.1	2	0.416017467058
network.snap	0.15	2	0.519998415387
network.snap	0.2	2	0.593631237841
network.snap	0.25	2	0.650976693189
network.snap	0.3	2	0.697669442697
"""

from __future__ import division     # So division returns a float.

import matplotlib.pyplot as plt
import os
import pprint
import re
import sys

# Parses the infected.out file and returns a hash of hashes of the following form:
# {
#   inputFile: {
#       t: infectedFraction
#   }
# }
def loadStatsFromFile(filename):
    stats = {}
    with open(filename) as f:
        while True:
            line = f.readline()
            if not line:
                # EOF.
                break
            line = line.strip()

            # Skip comment lines.
            if line.startswith("#"):
                continue

            (inputFile, t, iters, infectedFraction) = line.split("\t")
            if inputFile not in stats:
                stats[inputFile] = {}
            # Note: We don't actually use the iters field in the plot, so ignoring it.
            stats[inputFile][t] = infectedFraction
    return stats

# Takes one of the inputFile hashes from the above function and returns a tuple
# of two lists, for the X and Y axes, for plotting t vs infectedFraction.
def processStatsForOneInputFile(stats):
    x = []
    y = []
    for key in sorted(stats):
        x.append(key)
        y.append(stats[key])
    return (x, y)

def plotInputFile(inputFileName, x, y):
    # Just use the input filename as the extension, but strip the extension so
    # it looks a little prettier. i.e. if the input file was SampleRndGraph.txt
    # then the label will show "SampleRndGraph".
    label = re.sub(r'\.[^.]+$', '', inputFileName)
    plt.plot(x, y, ms=4, lw=1, marker='o', label=label)

def displayPlot(outputFileName):
    plt.title("Ebola Epidemic infection simulation")
    plt.xlabel('Transmissibility')
    plt.ylabel('Fraction of network infected')
    #plt.legend(loc='lower right')
    plt.legend(loc='upper left')

    plt.axvline(x=0.0001, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    plt.text(0.0001 + 0.0035, 0.10, 'Liberia')
    plt.axvline(x=0.1148, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    plt.text(0.1148 + 0.0035, 0.15, 'Guinea')
    plt.axvline(x=0.1243, ymin=0, ymax=1.0 , linewidth=1,alpha=0.2)
    plt.text(0.1243 + 0.0035, 0.20, 'Sierra Leone')

    plt.savefig(outputFileName)

def plotStats(stats, outputFileName):
    #pprint.pprint(stats)
    for inputFile in stats:
        (x, y) = processStatsForOneInputFile(stats[inputFile])
        plotInputFile(inputFile, x, y)
    displayPlot(outputFileName)

def main():
    # Parse command line arguments.
    if len(sys.argv) != 3:
        print >> sys.stderr, "Usage: %s statsFile imageOutFile" % sys.argv[0]
        print >> sys.stderr, "Example: %s infected.out infected-plot.png" % sys.argv[0]
        sys.exit(1)
    statsFile = sys.argv[1]
    imageOutFile = sys.argv[2]

    print "Loading stats from file: %s ..." % (statsFile)
    stats = loadStatsFromFile(statsFile)

    print "Plotting stats to output image: %s ..." % imageOutFile
    plotStats(stats, imageOutFile)

    sys.exit(0)

if __name__ == '__main__':
    main()
