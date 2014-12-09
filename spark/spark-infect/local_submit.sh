#!/bin/sh -xe
###################################################
spark-submit --driver-memory 12g --master local[8] --class edu.stanford.cs224w.SEIRSimulation target/spark-infect-1.0-SNAPSHOT.jar $*
