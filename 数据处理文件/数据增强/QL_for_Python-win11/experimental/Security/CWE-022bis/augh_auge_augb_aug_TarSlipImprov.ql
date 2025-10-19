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
API::Node tarfileOpenMethod() {
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
    this = tarfileOpenMethod().getACall()
    or
    exists(API::Node contextLibClosing, Node tarArchiveCall |
      contextLibClosing = API::moduleImport("contextlib").getMember("closing") and
      this = contextLibClosing.getACall() and
      tarArchiveCall = this.getArg(0) and
      tarArchiveCall = tarfileOpenMethod().getACall()
    )
  }
}

/**
 * Enhanced taint tracking configuration for TarSlip vulnerability detection
 */
private module TarSlipConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source = tarfileOpenMethod().getACall() 
  }

  predicate isSink(DataFlow::Node sink) {
    exists(TarfileOpenCall tarArchiveCall |
      // Handle extractall() without members parameter
      exists(MethodCallNode extractionCall |
        extractionCall = tarArchiveCall.getReturn().getMember("extractall").getACall() and
        not extractionCall.getArgByName("members") instanceof Node and
        sink = extractionCall.getObject()
      )
      or
      // Handle extractall() with members parameter
      exists(MethodCallNode extractionCall, Node membersParameter |
        extractionCall = tarArchiveCall.getReturn().getMember("extractall").getACall() and
        membersParameter = extractionCall.getArgByName("members") and
        (
          membersParameter.asCfgNode() instanceof NameConstantNode or
          membersParameter.asCfgNode() instanceof ListNode
        ) and
        sink = extractionCall.getObject()
      )
      or
      // Handle extractall() with dynamic members
      exists(MethodCallNode extractionCall, MethodCallNode getmembersInvocation |
        extractionCall = tarArchiveCall.getReturn().getMember("extractall").getACall() and
        getmembersInvocation = extractionCall.getArgByName("members") and
        getmembersInvocation.getMethodName() = "getmembers" and
        sink = getmembersInvocation.getObject()
      )
      or
      // Handle extract() method
      exists(MethodCallNode extractionCall |
        extractionCall = tarArchiveCall.getReturn().getMember("extract").getACall() and
        sink = extractionCall.getArg(0)
      )
      or
      // Handle _extract_member() method
      exists(MethodCallNode extractionCall, AttrRead nameAttribute |
        extractionCall = tarArchiveCall.getReturn().getMember("_extract_member").getACall() and
        nameAttribute = extractionCall.getArg(1).(AttrRead) and
        nameAttribute.accesses(sink, "name")
      )
    ) and
    not sink.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    // Flow through getmembers() method calls
    nodeTo.(MethodCallNode).calls(nodeFrom, "getmembers") and
    nodeFrom instanceof TarfileOpenCall
    or
    // Flow through contextlib.closing wrapper
    exists(API::CallNode contextLibClosingInvocation |
      contextLibClosingInvocation = API::moduleImport("contextlib").getMember("closing").getACall() and
      nodeTo = contextLibClosingInvocation and
      nodeFrom = contextLibClosingInvocation.getArg(0) and
      nodeFrom = tarfileOpenMethod().getReturn().getAValueReachableFromSource()
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