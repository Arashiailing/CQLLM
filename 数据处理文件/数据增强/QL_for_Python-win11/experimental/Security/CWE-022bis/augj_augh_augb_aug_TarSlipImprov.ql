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
class TarfileExtractionCall extends API::CallNode {
  TarfileExtractionCall() {
    this = tarfileOpenMethod().getACall()
    or
    exists(API::Node contextlibClosing, Node tarCall |
      contextlibClosing = API::moduleImport("contextlib").getMember("closing") and
      this = contextlibClosing.getACall() and
      tarCall = this.getArg(0) and
      tarCall = tarfileOpenMethod().getACall()
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
    exists(TarfileExtractionCall tarfileCall |
      // Handle extractall() without members parameter
      exists(MethodCallNode extractallCall |
        extractallCall = tarfileCall.getReturn().getMember("extractall").getACall() and
        not extractallCall.getArgByName("members") instanceof Node and
        sink = extractallCall.getObject()
      )
      or
      // Handle extractall() with members parameter
      exists(MethodCallNode extractallCall, Node membersArg |
        extractallCall = tarfileCall.getReturn().getMember("extractall").getACall() and
        membersArg = extractallCall.getArgByName("members") and
        (
          membersArg.asCfgNode() instanceof NameConstantNode or
          membersArg.asCfgNode() instanceof ListNode
        ) and
        sink = extractallCall.getObject()
      )
      or
      // Handle extractall() with dynamic members
      exists(MethodCallNode extractallCall, MethodCallNode getmembersCall |
        extractallCall = tarfileCall.getReturn().getMember("extractall").getACall() and
        getmembersCall = extractallCall.getArgByName("members") and
        getmembersCall.getMethodName() = "getmembers" and
        sink = getmembersCall.getObject()
      )
      or
      // Handle extract() method
      exists(MethodCallNode extractCall |
        extractCall = tarfileCall.getReturn().getMember("extract").getACall() and
        sink = extractCall.getArg(0)
      )
      or
      // Handle _extract_member() method
      exists(MethodCallNode extractMemberCall, AttrRead nameAttr |
        extractMemberCall = tarfileCall.getReturn().getMember("_extract_member").getACall() and
        nameAttr = extractMemberCall.getArg(1).(AttrRead) and
        nameAttr.accesses(sink, "name")
      )
    ) and
    not sink.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    // Flow through getmembers() method calls
    exists(MethodCallNode getmembersCall |
      getmembersCall.calls(nodeFrom, "getmembers") and
      nodeTo = getmembersCall and
      nodeFrom instanceof TarfileExtractionCall
    )
    or
    // Flow through contextlib.closing wrapper
    exists(API::CallNode contextlibClosingCall |
      contextlibClosingCall = API::moduleImport("contextlib").getMember("closing").getACall() and
      nodeTo = contextlibClosingCall and
      nodeFrom = contextlibClosingCall.getArg(0) and
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