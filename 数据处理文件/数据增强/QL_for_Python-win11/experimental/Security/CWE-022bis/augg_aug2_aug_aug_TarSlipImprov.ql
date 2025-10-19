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
API::Node tarfileExtractionEntryPoint() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]), 
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open")
    ]
}

/**
 * Detects tarfile extraction operations including contextlib.closing wrappers
 */
class TarfileExtractionOperation extends API::CallNode {
  TarfileExtractionOperation() {
    this = tarfileExtractionEntryPoint().getACall() 
    or
    exists(API::Node contextLibClosingNode, Node wrappedExtractionCall |
      contextLibClosingNode = API::moduleImport("contextlib").getMember("closing") and 
      this = contextLibClosingNode.getACall() and 
      wrappedExtractionCall = this.getArg(0) and 
      wrappedExtractionCall = tarfileExtractionEntryPoint().getACall()
    )
  }
}

/**
 * Enhanced taint tracking configuration for TarSlip vulnerability detection
 */
private module TarSlipEnhancedFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode = tarfileExtractionEntryPoint().getACall() 
  }

  predicate isSink(DataFlow::Node sinkNode) {
    exists(TarfileExtractionOperation tarExtraction |
      // Case 1: extractall without members parameter
      exists(MethodCallNode extractAllMethodCall |
        extractAllMethodCall = tarExtraction.getReturn().getMember("extractall").getACall() and 
        not exists(Node arg | arg = extractAllMethodCall.getArgByName("members")) and 
        sinkNode = extractAllMethodCall.getObject()
      )
      or
      // Case 2: extractall with members parameter
      exists(MethodCallNode extractAllMethodCall, Node membersArg |
        extractAllMethodCall = tarExtraction.getReturn().getMember("extractall").getACall() and 
        membersArg = extractAllMethodCall.getArgByName("members") and 
        (
          // Safe: members is constant None or list
          (membersArg.asCfgNode() instanceof NameConstantNode or 
           membersArg.asCfgNode() instanceof ListNode) and 
          sinkNode = extractAllMethodCall.getObject()
          or
          // Dangerous: members from getmembers call
          exists(MethodCallNode getMembersMethodCall |
            getMembersMethodCall = membersArg and 
            getMembersMethodCall.getMethodName() = "getmembers" and 
            sinkNode = getMembersMethodCall.getObject()
          )
          or
          // Dangerous: members is arbitrary expression
          not (membersArg.asCfgNode() instanceof NameConstantNode or 
               membersArg.asCfgNode() instanceof ListNode) and 
          not exists(MethodCallNode getMembersMethodCall |
            getMembersMethodCall = membersArg and 
            getMembersMethodCall.getMethodName() = "getmembers"
          ) and 
          sinkNode = membersArg
        )
      )
      or
      // Case 3: path parameter in extract method
      sinkNode = tarExtraction.getReturn().getMember("extract").getACall().getArg(0)
      or
      // Case 4: name attribute access in _extract_member method
      exists(MethodCallNode extractMemberMethodCall |
        extractMemberMethodCall = tarExtraction.getReturn().getMember("_extract_member").getACall() and 
        extractMemberMethodCall.getArg(1).(AttrRead).accesses(sinkNode, "name")
      )
    ) and
    not sinkNode.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    // Flow through getmembers method calls
    toNode.(MethodCallNode).calls(fromNode, "getmembers") and 
    fromNode instanceof TarfileExtractionOperation
    or
    // Flow through contextlib.closing wrappers
    toNode = API::moduleImport("contextlib").getMember("closing").getACall() and 
    fromNode = toNode.(API::CallNode).getArg(0) and 
    fromNode = tarfileExtractionEntryPoint().getReturn().getAValueReachableFromSource()
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking configuration for enhanced TarSlip vulnerability detection */
module TarSlipImprovFlow = TaintTracking::Global<TarSlipEnhancedFlowConfig>;

from TarSlipImprovFlow::PathNode source, TarSlipImprovFlow::PathNode sink
where TarSlipImprovFlow::flowPath(source, sink)
select sink, source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()