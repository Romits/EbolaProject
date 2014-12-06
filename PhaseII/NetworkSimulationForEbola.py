"""
Code for Simulating Ebola Data on various
Network models to compare the spread of the 
Epidemic

"""
import snap
import matplotlib.pyplot as plt
import random
import numpy as np

def loadGraphPrintStats(inputFile, graphType):
    outGraph = snap.LoadEdgeList(snap.PNGraph, inputFile, 0,1, '\t')
    nodeCount = snap.CntNonZNodes(outGraph)
    edgeCount = snap.CntUniqUndirEdges(outGraph)
    avgDeg = float(edgeCount)/nodeCount
    print "Average Degree for %s graph is %f" % (graphType, avgDeg)
    return outGraph

def runSimulations(inputGraph, T, noOfIters):
    numOfNodes = snap.CntNonZNodes(inputGraph)
    avgSize = list()
    for T0 in T:
        sum = 0
        for simCount in range(0,int(noOfIters)):
            infectedPatientList = list()
            patientIdList = list()
            patientZero = inputGraph.GetRndNId() # choose patient zero
            infectedPatientList.append(patientZero)
            while len(infectedPatientList) > 0:
                node = infectedPatientList.pop(0)
                neighbors = snap.TIntV()
                snap.GetCmnNbrs(inputGraph, node, node, neighbors)
                for neighbor in neighbors:
                    if neighbor not in infectedPatientList and neighbor not in patientIdList:
                        if random.random() < T0:
                            infectedPatientList.append(neighbor)
                patientIdList.append(node) 
            sum = sum + len(patientIdList)
        avgSize.append(float(sum/noOfIters)/numOfNodes)
    return avgSize

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
    T = np.linspace(0.000,0.2500,10) # Liberia, Guinea,Sierra Leone
    print T
    simIter = 2000
    random.seed(21)
    PAGraph = loadGraphPrintStats('SamplePAGraph.txt','Preferential Attachment')
    resultListRN = runSimulations(PAGraph, T, simIter)
    print resultListRN
    RndGraph = loadGraphPrintStats('SampleRndGraph.txt','Random Network')
    resultListRnd = runSimulations(RndGraph, T, simIter)
    print resultListRnd
    SWGraph = loadGraphPrintStats('SampleSWGraph.txt','SmallWorld Network')
    resultListSW = runSimulations(SWGraph, T, simIter)
    plotData(resultListRN, resultListRnd, resultListSW, T)


 
if __name__ == '__main__':
    main()
