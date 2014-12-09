package edu.stanford.cs224w

import scala.collection.mutable
import org.apache.spark._
import org.apache.spark.storage.StorageLevel
import org.apache.spark.graphx._

import scala.util.Random

class SEIRSimulation(inputFileC : String,
                     patientZeroIdC : VertexId,
                     transmissibilityC : Float,
                     maxDaysC : Int,
                     numEPartC : Int,
                     outFileC : String,
                     optionsC : Map[String, String]) extends Logging with Serializable {

  // Node attribute tuple: (State  : S/E/I/R, Time in state).
  type VertexDataType = (Int, Int)
  type EdgeDataType = Int
  // It comes like this out of the box.
  type MsgType = Int

  // States (S, E, I, R).
  val SusceptibleState: Int = 0
  val ExposedState: Int = 1
  val InfectiousState: Int = 2
  val RecoveredState: Int = 3

  // Types of messages.
  // A message is simply an integer.
  val InitializeMsg: Int = 0
  val StepMsg: Int = 1
  val InfectMsg: Int = 2

  val ZeroTimeInState: Int = 0
  val StateTransitionPeriod: Int = 11 // We transition E->I and I->R in 11 days.

  // Members from constructor args.
  val inputFile : String = inputFileC
  val patientZeroId : VertexId = patientZeroIdC
  val transmissibility : Float = transmissibilityC
  val maxDays : Int =  maxDaysC
  val numEPart : Int =  numEPartC
  val outFile : String =  outFileC
  val options : Map[String, String] = optionsC

  // What to do when we receive a message.
  def recvMsg(id: VertexId, vdata: VertexDataType, msg: MsgType): VertexDataType = {

    var state = vdata._1
    var timeInState = vdata._2

    // DEBUG
    //println("=> Node " + id + " in state " + state + " received msg type " + msg)

    // Message from ourselves.
    if ((msg & StepMsg) != 0) {
      state match {
        case ExposedState => {
          println("=> Exposed node " + id + " received Step msg")
          if (timeInState >= StateTransitionPeriod) {
            state = InfectiousState
            timeInState = ZeroTimeInState
          } else {
            timeInState += 1
          }
        }
        case InfectiousState => {
          println("=> Infectious node " + id + " received Step msg")
          if (timeInState >= StateTransitionPeriod) {
            state = RecoveredState
            timeInState = ZeroTimeInState
          } else {
            timeInState += 1
          }
        }
      }
    }

    // Message from someone else to infect us.
    if ((msg & InfectMsg) != 0) {
      if (state == SusceptibleState) {
        // Enter incubation period.
        state = ExposedState
        timeInState = ZeroTimeInState
      }
    }

    return (state, timeInState)
  }

  // We received a message this turn. Now to process an outgoing edge.
  def sendMsg(triplet: EdgeTriplet[VertexDataType, EdgeDataType]): Iterator[(VertexId, MsgType)] = {
    if (triplet.srcId.equals(triplet.dstId)) {
      // If it's a self-edge, send a Step message if we're in E or I, since
      // they both have a period of time where they can be in that state.
      if (triplet.dstAttr._1 == ExposedState) {
        return Iterator((triplet.dstId, StepMsg))
      } else if (triplet.dstAttr._1 == InfectiousState) {
        return Iterator((triplet.dstId, StepMsg))
      }

    } else if (triplet.srcAttr._1 == InfectiousState && triplet.dstAttr._1 == SusceptibleState) {
      // Otherwise, if the source is infectious and the destination is
      // susceptible, infect it with some probability T.
      if (Random.nextFloat < transmissibility) {
        println("=> Node " + triplet.srcId + " infecting node " + triplet.dstId)
        return Iterator((triplet.dstId, InfectMsg))
      }
    } else if (triplet.dstAttr._1 == InfectiousState && triplet.srcAttr._1 == SusceptibleState) {
      // Treat the digraph as an undirected graph.
      if (Random.nextFloat < transmissibility) {
        println("=> Node " + triplet.dstId + " infecting node " + triplet.srcId)
        return Iterator((triplet.srcId, InfectMsg))
      }
    }

    return Iterator.empty
  }

  def mergeMessages(a : MsgType, b : MsgType) : MsgType = {
    return a | b // Bitwise union, since each message type is idempotent.
  }

  def myPregel(graph: Graph[VertexDataType, EdgeDataType]) : Graph[VertexDataType, EdgeDataType] = {

    println("==> Running initial map...")
    var g = graph.mapVertices((vid, vdata) => recvMsg(vid, vdata, InitializeMsg)).cache()

    // compute the messages
    println("==> Reducing on triplets...")
    var messages = g.mapReduceTriplets(sendMsg, mergeMessages)
    var activeMessages = messages.count()
    // Loop
    var prevG: Graph[VertexDataType, EdgeDataType] = null
    var i = 0
    while (activeMessages > 0 && i < maxDays) {

      println("==> Inner join on receiving messages...")
      // Receive the messages. Vertices that didn't get any messages do not appear in newVerts.
      val newVerts = g.vertices.innerJoin(messages)(recvMsg).cache()

      if (i % 90 == 0) {
        val incrOutFile : String = outFile + ".incremental." + i
        println("==> Dumping infected vertices for iteration " + i + " to file " + incrOutFile)
        dumpInfectedVertices(g, incrOutFile)
      }

      // HACK: We are only doing this count to materialize this thing so mapReduceTriplets() doesn't
      // go into some weird loop. This line slows us down a bit by adding an additional reduce step,
      // but fixes a bug. I don't know why it fixes the bug.
      val numNewVerts = newVerts.count()

      println("==> Outer join for updated vertices, number of new vertices = " + numNewVerts + "...")
      // Update the graph with the new vertices.
      prevG = g
      g = g.outerJoinVertices(newVerts) { (vid, old, newOpt) => newOpt.getOrElse(old) }

      val oldMessages = messages
      println("==> Sending new messages...")
      // Send new messages. Vertices that didn't get any messages don't appear in newVerts, so don't
      // get to send messages. We must cache messages so it can be materialized on the next line,
      // allowing us to uncache the previous iteration.
      messages = g.mapReduceTriplets(sendMsg, mergeMessages, Some((newVerts, EdgeDirection.Either))).cache()
      // The call to count() materializes `messages`, `newVerts`, and the vertices of `g`. This
      // hides oldMessages (depended on by newVerts), newVerts (depended on by messages), and the
      // vertices of prevG (depended on by newVerts, oldMessages, and the vertices of g).
      activeMessages = messages.count()

      println("==> Pregel finished iteration " + i + " with active messages = " + activeMessages)


      // Unpersist the RDDs hidden by newly-materialized RDDs
      oldMessages.unpersist(blocking=false)
      newVerts.unpersist(blocking=false)
      prevG.unpersistVertices(blocking=false)
      prevG.edges.unpersist(blocking=false)
      // count the iteration
      i += 1
    }

    g
  }

  def run(sc : SparkContext,
          edgeStorageLevel : StorageLevel,
          vertexStorageLevel : StorageLevel,
          partitionStrategy : Option[PartitionStrategy]) : Int = {

    println("=======================")
    println("    SEIR Simulation    ")
    println("=======================")

    println("Loading edge list file: " + inputFile)
    val unpartitionedGraph = GraphLoader.edgeListFile(sc, inputFile,
      minEdgePartitions = numEPart,
      edgeStorageLevel = edgeStorageLevel,
      vertexStorageLevel = vertexStorageLevel).cache()

    println("Partitioning file into graph...")
    val rawGraph = partitionStrategy.foldLeft(unpartitionedGraph)(_.partitionBy(_))

    // Initial values for patient zero.
    val patientZeroAttrs = (patientZeroId, (InfectiousState, ZeroTimeInState)) // Starts out infected.
    val patientZeroRDD = sc.parallelize(Array(patientZeroAttrs))

    // Transform to attribute graph we want by attaching the user attributes.
    val graph = rawGraph.outerJoinVertices(patientZeroRDD) {
      case (uid, degree, Some(attributes)) => attributes              // Patient zero.
      case (uid, degree, None) => (SusceptibleState, ZeroTimeInState) // Everyone else.
    }.cache()

    println("===============================")
    println("==> Stats:")
    println("==> GRAPHX: Number of vertices " + graph.vertices.count)
    println("==> GRAPHX: Number of edges " + graph.edges.count)
    println("===============================")

    /*
    // BUG: 
    val g = graph.mapVertices((vid, vdata) => recvMsg(vid, vdata, InitializeMsg))

    println("===============================")
    println("=> AGAIN Stats:")
    println("=> AGAIN GRAPHX: Number of vertices " + g.vertices.count)
    println("=> AGAIN GRAPHX: Number of edges " + g.edges.count)
    println("===============================")

    if (true) return 0
    */

    println("==> Running pregel-based infection algorithm...")
    //val resultGraph = graph.pregel(InitializeMsg, maxDays, EdgeDirection.Out)(recvMsg, sendMsg, mergeMessages).cache()
    val resultGraph = myPregel(graph).cache()

    dumpInfectedVertices(resultGraph, outFile)

    return 0
  }

  // Output the infected node ids to a file.
  def dumpInfectedVertices(graph : Graph[VertexDataType, EdgeDataType], filename : String) : Int = {
    //val infectedVertices = resultGraph.vertices.filter((vid : VertexId, attrs : SEIRAttrs) => attrs._1 != SusceptibleState)
    val infectedVertices = graph.vertices.filter {
      case (id, (state, duration)) => state != SusceptibleState
    }

    // Dump the data to a single output file.
    println("Dumping results to out file...")
    infectedVertices.mapValues((vid, attrs) => ())
                    .coalesce(numPartitions = 1, shuffle = true)
                    .saveAsTextFile(filename)

    return 0
  }
}


object SEIRSimulation {
  def main(args: Array[String]): Unit = {
    if (args.length < 6) {
      System.err.println(
        "Usage: SEIRSimulation inputFile patientZeroId transmissibility maxDays edgePartitions outFile [options]")
      System.exit(1)
    }

    val inputFile = args(0)
    val patientZeroId = args(1).toLong
    val transmissibility = args(2).toFloat
    val maxDays = args(3).toInt
    val numEPart = args(4).toInt
    val outFile = args(5)

    // Optional arguments
    val optionsList = args.drop(6).map {
      arg => arg.dropWhile(_ == '-').split('=') match {
        case Array(opt, v) => opt -> v
        case _ => throw new IllegalArgumentException("Invalid argument: " + arg)
      }
    }
    val options = mutable.Map(optionsList: _*)

    val partitionStrategy: Option[PartitionStrategy] = options.remove("partStrategy")
      .map(PartitionStrategy.fromString(_))
    val edgeStorageLevel = options.remove("edgeStorageLevel")
      .map(StorageLevel.fromString(_)).getOrElse(StorageLevel.MEMORY_ONLY)
    val vertexStorageLevel = options.remove("vertexStorageLevel")
      .map(StorageLevel.fromString(_)).getOrElse(StorageLevel.MEMORY_ONLY)

    val conf = new SparkConf()
      .set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
      .set("spark.kryo.registrator", "org.apache.spark.graphx.GraphKryoRegistrator")
      //.set("spark.locality.wait", "100000") // Avoid remote communication.

    val sc = new SparkContext(conf.setAppName("SEIR(" + inputFile + ")"))

    val immutableOptions = options.toMap
    val sim = new SEIRSimulation(inputFile, patientZeroId, transmissibility, maxDays, numEPart, outFile, immutableOptions)
    sim.run(sc, edgeStorageLevel, vertexStorageLevel, partitionStrategy)

    sc.stop()
  }
}
