import snap

Rnd = snap.TRnd(1,0)
#smallWorldG = snap.GenSmallWorld(485, 9, 0, Rnd)
#snap.SaveEdgeList(smallWorldG, "SampleSWGraph.txt", "SaveGraph")
smallWorldG = snap.GenSmallWorld(4846609, 9, 0, Rnd)
snap.SaveEdgeList(smallWorldG, "SWGraph.txt", "SaveGraph")



