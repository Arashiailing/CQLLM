/**
 * @name Arbitrary file write during tarfile extraction
 * @description Detects unsafe tar extraction where malicious archives can write files outside target directories via path traversal sequences. 
 *              This occurs when extraction operations don't validate destination paths, allowing attackers to overwrite arbitrary files.
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
 * Identifies tarfile extraction entry points including:
 *  - Direct `tarfile.open()` calls
 *  - Direct `tarfile.TarFile()` calls
 *  - Subclass method invocations (e.g., `MKtarfile.Tarfile.open()`)
 */
API::Node tarfileExtractionOperation() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]), 
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open")
    ]
}

/**
 * Detects tarfile extraction operations including contextlib.closing wrappers
 */
class TarfileExtractionCall extends API::CallNode {
  TarfileExtractionCall() {
    this = tarfileExtractionOperation().getACall() 
    or
    exists(API::Node contextClosingNode, Node wrappedExtractionCall |
      contextClosingNode = API::moduleImport("contextlib").getMember("closing") and 
      this = contextClosingNode.getACall() and 
      wrappedExtractionCall = this.getArg(0) and 
      wrappedExtractionCall = tarfileExtractionOperation().getACall()
    )
  }
}

/**
 * Enhanced taint tracking configuration for TarSlip vulnerability detection
 */
private module TarSlipEnhancedFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) { 
    src = tarfileExtractionOperation().getACall() 
  }

  predicate isSink(DataFlow::Node dest) {
    exists(TarfileExtractionCall tarExtraction |
      // Case 1: extractall without members parameter
      exists(MethodCallNode extractAllCall |
        extractAllCall = tarExtraction.getReturn().getMember("extractall").getACall() and 
        not exists(Node arg | arg = extractAllCall.getArgByName("members")) and 
        dest = extractAllCall.getObject()
      )
      or
      // Case 2: extractall with members parameter
      exists(MethodCallNode extractAllCall, Node membersParam |
        extractAllCall = tarExtraction.getReturn().getMember("extractall").getACall() and 
        membersParam = extractAllCall.getArgByName("members") and 
        (
          // Safe: members is constant None or list
          (membersParam.asCfgNode() instanceof NameConstantNode or 
           membersParam.asCfgNode() instanceof ListNode) and 
          dest = extractAllCall.getObject()
          or
          // Dangerous: members from getmembers call
          exists(MethodCallNode getMembersCall |
            getMembersCall = membersParam and 
            getMembersCall.getMethodName() = "getmembers" and 
            dest = getMembersCall.getObject()
          )
          or
          // Dangerous: members is arbitrary expression
          not (membersParam.asCfgNode() instanceof NameConstantNode or 
               membersParam.asCfgNode() instanceof ListNode) and 
          not exists(MethodCallNode getMembersCall |
            getMembersCall = membersParam and 
            getMembersCall.getMethodName() = "getmembers"
          ) and 
          dest = membersParam
        )
      )
      or
      // Case 3: path parameter in extract method
      dest = tarExtraction.getReturn().getMember("extract").getACall().getArg(0)
      or
      // Case 4: name attribute access in _extract_member method
      exists(MethodCallNode extractMemberCall |
        extractMemberCall = tarExtraction.getReturn().getMember("_extract_member").getACall() and 
        extractMemberCall.getArg(1).(AttrRead).accesses(dest, "name")
      )
    ) and
    not dest.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    // Flow through getmembers method calls
    toNode.(MethodCallNode).calls(fromNode, "getmembers") and 
    fromNode instanceof TarfileExtractionCall
    or
    // Flow through contextlib.closing wrappers
    toNode = API::moduleImport("contextlib").getMember("closing").getACall() and 
    fromNode = toNode.(API::CallNode).getArg(0) and 
    fromNode = tarfileExtractionOperation().getReturn().getAValueReachableFromSource()
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking configuration for enhanced TarSlip vulnerability detection */
module TarSlipImprovFlow = TaintTracking::Global<TarSlipEnhancedFlowConfig>;

from TarSlipImprovFlow::PathNode source, TarSlipImprovFlow::PathNode sink
where TarSlipImprovFlow::flowPath(source, sink)
select sink, source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()