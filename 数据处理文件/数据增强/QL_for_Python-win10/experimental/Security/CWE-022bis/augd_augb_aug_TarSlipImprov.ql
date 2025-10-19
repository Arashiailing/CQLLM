/**
 * @name Arbitrary file write during tarfile extraction
 * @description Detects when malicious tar archives overwrite files outside target directory due to unvalidated extraction paths
 * @kind path-problem
 * @id py/tarslip-extended
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import TarSlipFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.internal.Attributes
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.dataflow.new.RemoteFlowSources

/**
 * Identifies tarfile opening methods:
 *  - `tarfile.open()`
 *  - `tarfile.TarFile()`
 *  - Subclasses' `open` methods
 */
API::Node tarfileOpenApiNode() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]),
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open")
    ]
}

/**
 * Handles direct tarfile calls and contextlib.closing wrappers
 */
class TarfileOpenCall extends API::CallNode {
  TarfileOpenCall() {
    this = tarfileOpenApiNode().getACall()
    or
    exists(API::Node contextlibClosingNode, Node tarfileCallNode |
      contextlibClosingNode = API::moduleImport("contextlib").getMember("closing") and
      this = contextlibClosingNode.getACall() and
      tarfileCallNode = this.getArg(0) and
      tarfileCallNode = tarfileOpenApiNode().getACall()
    )
  }
}

/**
 * Enhanced taint tracking configuration for TarSlip vulnerability detection
 */
private module TarSlipConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode = tarfileOpenApiNode().getACall() 
  }

  predicate isSink(DataFlow::Node sinkNode) {
    exists(TarfileOpenCall tarOpener |
      // Handle extractall() without members parameter
      (
        exists(MethodCallNode extractCall |
          extractCall = tarOpener.getReturn().getMember("extractall").getACall() and
          not extractCall.getArgByName("members") instanceof Node and
          sinkNode = extractCall.getObject()
        )
      )
      or
      // Handle extractall() with members parameter
      (
        exists(MethodCallNode extractCall, Node membersArg |
          extractCall = tarOpener.getReturn().getMember("extractall").getACall() and
          membersArg = extractCall.getArgByName("members") and
          (
            membersArg.asCfgNode() instanceof NameConstantNode or
            membersArg.asCfgNode() instanceof ListNode
          ) and
          sinkNode = extractCall.getObject()
        )
      )
      or
      // Handle extractall() with dynamic members
      (
        exists(MethodCallNode extractCall, MethodCallNode getMembersCall |
          extractCall = tarOpener.getReturn().getMember("extractall").getACall() and
          getMembersCall = extractCall.getArgByName("members") and
          getMembersCall.getMethodName() = "getmembers" and
          sinkNode = getMembersCall.getObject()
        )
      )
      or
      // Handle extract() method
      (
        exists(MethodCallNode extractCall |
          extractCall = tarOpener.getReturn().getMember("extract").getACall() and
          sinkNode = extractCall.getArg(0)
        )
      )
      or
      // Handle _extract_member() method
      (
        exists(MethodCallNode extractCall, AttrRead nameAttr |
          extractCall = tarOpener.getReturn().getMember("_extract_member").getACall() and
          nameAttr = extractCall.getArg(1).(AttrRead) and
          nameAttr.accesses(sinkNode, "name")
        )
      )
    ) and
    not sinkNode.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    // Flow through getmembers() method calls
    (
      toNode.(MethodCallNode).calls(fromNode, "getmembers") and
      fromNode instanceof TarfileOpenCall
    )
    or
    // Flow through contextlib.closing wrapper
    (
      exists(API::CallNode closingCall |
        closingCall = API::moduleImport("contextlib").getMember("closing").getACall() and
        toNode = closingCall and
        fromNode = closingCall.getArg(0) and
        fromNode = tarfileOpenApiNode().getReturn().getAValueReachableFromSource()
      )
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking for enhanced TarSlip vulnerability detection */
module TarSlipFlow = TaintTracking::Global<TarSlipConfig>;

from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
where TarSlipFlow::flowPath(source, sink)
select sink, source, sink, "Extraction of tarfile from $@ to potentially unsafe location $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()