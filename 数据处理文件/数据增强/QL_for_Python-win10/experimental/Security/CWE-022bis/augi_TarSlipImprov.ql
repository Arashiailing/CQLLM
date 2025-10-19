/**
 * @name Arbitrary file write during tarfile extraction
 * @description Extracting files from a malicious tar archive without verifying target paths 
 *              can lead to overwriting files outside the target directory.
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
import TarSlipImprovFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.internal.Attributes
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.dataflow.new.RemoteFlowSources

/**
 * Identifies tarfile opening operations including:
 *  - `tarfile.open()`
 *  - `tarfile.TarFile()`
 *  - Subclasses of TarFile using `open()`
 */
API::Node tarfileOpenCall() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]),
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open")
    ]
}

/**
 * Represents all tarfile opening operations including:
 *  - Direct tarfile.open() calls
 *  - TarFile constructor calls
 *  - Subclass open() calls
 *  - Operations wrapped in contextlib.closing()
 */
class AllTarfileOpens extends API::CallNode {
  AllTarfileOpens() {
    this = tarfileOpenCall().getACall()
    or
    exists(API::Node closingWrapper, Node wrappedCall |
      closingWrapper = API::moduleImport("contextlib").getMember("closing") and
      this = closingWrapper.getACall() and
      wrappedCall = this.getArg(0) and
      wrappedCall = tarfileOpenCall().getACall()
    )
  }
}

/**
 * Taint tracking configuration for detecting TarSlip vulnerabilities.
 */
private module TarSlipImprovConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source = tarfileOpenCall().getACall() 
  }

  predicate isSink(DataFlow::Node sink) {
    exists(AllTarfileOpens tarfileOperation |
      // Case 1: extractall() without members parameter
      exists(MethodCallNode extractCall |
        extractCall = tarfileOperation.getReturn().getMember("extractall").getACall() and
        not exists(Node arg | arg = extractCall.getArgByName("members")) and
        sink = extractCall.getObject()
      )
      or
      // Case 2: extractall() with members parameter
      exists(MethodCallNode extractCall, Node membersArg |
        extractCall = tarfileOperation.getReturn().getMember("extractall").getACall() and
        membersArg = extractCall.getArgByName("members") and
        (
          // Safe members: None, List, or getmembers() call
          (membersArg.asCfgNode() instanceof NameConstantNode or 
           membersArg.asCfgNode() instanceof ListNode) and
          sink = extractCall.getObject()
          or
          // Unsafe members: getmembers() call object
          exists(MethodCallNode getmembersCall |
            getmembersCall = membersArg and
            getmembersCall.getMethodName() = "getmembers" and
            sink = getmembersCall.getObject()
          )
          or
          // Unsafe members: arbitrary expression
          not (membersArg.asCfgNode() instanceof NameConstantNode or 
               membersArg.asCfgNode() instanceof ListNode) and
          not exists(MethodCallNode getmembersCall |
            getmembersCall = membersArg and
            getmembersCall.getMethodName() = "getmembers"
          ) and
          sink = membersArg
        )
      )
      or
      // Case 3: extract() method parameter
      sink = tarfileOperation.getReturn().getMember("extract").getACall().getArg(0)
      or
      // Case 4: _extract_member() method parameter
      exists(MethodCallNode extractCall |
        extractCall = tarfileOperation.getReturn().getMember("_extract_member").getACall() and
        extractCall.getArg(1).(AttrRead).accesses(sink, "name")
      )
    ) and
    not sink.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    // Step 1: getmembers() method call
    nodeTo.(MethodCallNode).calls(nodeFrom, "getmembers") and
    nodeFrom instanceof AllTarfileOpens
    or
    // Step 2: contextlib.closing() wrapper
    exists(API::CallNode closingCall |
      closingCall = API::moduleImport("contextlib").getMember("closing").getACall() and
      nodeTo = closingCall and
      nodeFrom = closingCall.getArg(0) and
      nodeFrom = tarfileOpenCall().getReturn().getAValueReachableFromSource()
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking for TarSlip vulnerability detection. */
module TarSlipImprovFlow = TaintTracking::Global<TarSlipImprovConfig>;

from TarSlipImprovFlow::PathNode source, TarSlipImprovFlow::PathNode sink
where TarSlipImprovFlow::flowPath(source, sink)
select sink, source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()