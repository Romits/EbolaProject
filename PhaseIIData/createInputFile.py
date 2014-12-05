import sys
fp = open('FullNetworkGraph.txt', 'w')
for line in sys.stdin:
   line = line.strip().split()
   while line:
       nodes = line.pop(0)
       #print int(nodes)
       for node1 in range(0,int(nodes)):
           degree = line.pop(0)
           #print int(degree)
           for idx in range(0,int(degree)):
               node2 = line.pop(0)
               #print int(node1)
               #print int(node2)
               outstring = str(node1) + "," +  str(node2) + '\n'
               fp.write(outstring)
  



