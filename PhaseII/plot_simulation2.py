#!/usr/bn/env python
"""
Plot concatenation of outputs of diffusion_simulation.py
This ploting routines sorts numerically.
Based on plot_simulations.py

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
import seaborn as sns
sns.set_style("white")
#sns.set(palette="muted")

#sns.set_context("paper")

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
            print line
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
    for key in sorted(stats,key=float):
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
    plt.title("Ebola epidemic infection simulation")
    plt.xlabel('Patient Zero-Min Degree')
    plt.ylabel('Fraction of network infected')
    #plt.legend(loc='lower right')
    plt.legend(loc='lower right')

    #plt.axvline(x=0.0001, ymin=0, ymax=1.0 , color='k',linestyle='dashed',linewidth=0.5,alpha=0.5)
   # plt.text(0.0001 + 0.001, 0.10, 'Liberia',rotation='vertical',fontsize=6)
   # plt.axvline(x=0.1148, ymin=0, ymax=1.0, color='k', linestyle='dashed',linewidth=0.5,alpha=0.5)
   # plt.text(0.1148 + 0.001, 0.15, 'Guinea',rotation='vertical',fontsize=6)
   # plt.axvline(x=0.1243, ymin=0, ymax=1.0 ,linestyle='dashed',color='k', linewidth=0.5,alpha=0.5)
   # plt.text(0.1243 + 0.001, 0.20, 'Sierra Leone',rotation='vertical',fontsize=6)
   # plt.axvline(x=0.1275, ymin=0, ymax=1.0 ,color='k', linewidth=0.5)
   # plt.text(0.1243 + 0.0040, 0.45, 'Epidemic Threshold',rotation='vertical',fontsize=6)


    plt.savefig(outputFileName,format='pdf',figsize=(10,8))

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
