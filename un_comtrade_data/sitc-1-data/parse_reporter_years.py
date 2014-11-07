#!/usr/bin/python

import xml.etree.ElementTree as ET

filename = "DataAvailabilityList-S1-pretty.xml"
tree = ET.parse(filename)
root = tree.getroot()

reporters = {}
for r in root:
  reporter = r.findtext("reporter")
  year = r.findtext("year")
  if reporter not in reporters or reporters[reporter] < year:
    reporters[reporter] = year

for reporter in sorted(reporters):
  print "%s\t%s" % (reporters[reporter], reporter)
