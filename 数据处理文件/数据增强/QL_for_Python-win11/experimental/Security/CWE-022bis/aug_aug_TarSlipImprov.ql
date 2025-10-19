/**
 * @name Arbitrary file write during tarfile extraction
 * @description This vulnerability occurs when extracting files from a malicious tar archive without validating that destination paths remain within the target directory. 
 *              Attackers can exploit this to overwrite files outside the intended directory by crafting archives with malicious path traversal sequences.
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
 * Identifies all tarfile extraction operations including:
 *  - Direct calls to `tarfile.open()`
 *  - Direct calls to `tarfile.TarFile()`
 *  - Subclass method calls like `MKtarfile.Tarfile.open()`
 */
API::Node tarfileExtractionOperation() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]), 
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open")
    ]
}

/**
 * Detects all tarfile extraction operations, including those wrapped with contextlib.closing
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
  predicate isSource(DataFlow::Node extractionSource) { 
    extractionSource = tarfileExtractionOperation().getACall() 
  }

  predicate isSink(DataFlow::Node extractionSink) {
    exists(TarfileExtractionCall tarfileExtraction |
      // Handle extractall calls without members parameter
      exists(MethodCallNode extractAllCall |
        extractAllCall = tarfileExtraction.getReturn().getMember("extractall").getACall() and 
        not exists(Node arg | arg = extractAllCall.getArgByName("members")) and 
        extractionSink = extractAllCall.getObject()
      )
      or
      // Handle extractall calls with members parameter
      exists(MethodCallNode extractAllCall, Node membersParam |
        extractAllCall = tarfileExtraction.getReturn().getMember("extractall").getACall() and 
        membersParam = extractAllCall.getArgByName("members") and 
        (
          // Safe case: members is constant None or list
          (membersParam.asCfgNode() instanceof NameConstantNode or 
           membersParam.asCfgNode() instanceof ListNode) and 
          extractionSink = extractAllCall.getObject()
          or
          // Dangerous case: members from getmembers call
          exists(MethodCallNode getMembersCall |
            getMembersCall = membersParam and 
            getMembersCall.getMethodName() = "getmembers" and 
            extractionSink = getMembersCall.getObject()
          )
          or
          // Dangerous case: members is arbitrary expression
          not (membersParam.asCfgNode() instanceof NameConstantNode or 
               membersParam.asCfgNode() instanceof ListNode) and 
          not exists(MethodCallNode getMembersCall |
            getMembersCall = membersParam and 
            getMembersCall.getMethodName() = "getmembers"
          ) and 
          extractionSink = membersParam
        )
      )
      or
      // Handle path parameter in extract method
      extractionSink = tarfileExtraction.getReturn().getMember("extract").getACall().getArg(0)
      or
      // Handle name attribute access in _extract_member method
      exists(MethodCallNode extractMemberCall |
        extractMemberCall = tarfileExtraction.getReturn().getMember("_extract_member").getACall() and 
        extractMemberCall.getArg(1).(AttrRead).accesses(extractionSink, "name")
      )
    ) and
    not extractionSink.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    // Handle getmembers method call flow
    nodeTo.(MethodCallNode).calls(nodeFrom, "getmembers") and 
    nodeFrom instanceof TarfileExtractionCall
    or
    // Handle contextlib.closing wrapped flow
    nodeTo = API::moduleImport("contextlib").getMember("closing").getACall() and 
    nodeFrom = nodeTo.(API::CallNode).getArg(0) and 
    nodeFrom = tarfileExtractionOperation().getReturn().getAValueReachableFromSource()
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking configuration for enhanced TarSlip vulnerability detection */
module TarSlipImprovFlow = TaintTracking::Global<TarSlipEnhancedFlowConfig>;

from TarSlipImprovFlow::PathNode source, TarSlipImprovFlow::PathNode sink
where TarSlipImprovFlow::flowPath(source, sink)
select sink, source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()