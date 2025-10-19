/**
 * @name Tar extraction with path traversal vulnerability
 * @description This vulnerability arises when extracting files from a tar archive without proper path validation, allowing attackers to write files outside the intended extraction directory using malicious path sequences.
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
 * Identifies all tarfile extraction operations, which include:
 *  - Direct invocations of `tarfile.open()`
 *  - Direct invocations of `tarfile.TarFile()`
 *  - Method invocations on subclasses, such as `MKtarfile.Tarfile.open()`
 */
API::Node tarfileExtractionOperation() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]), 
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open")
    ]
}

/**
 * Represents all tarfile extraction operations, including those wrapped by contextlib.closing
 */
class TarfileExtractionCall extends API::CallNode {
  TarfileExtractionCall() {
    exists(API::CallNode extractionCall |
      extractionCall = tarfileExtractionOperation().getACall() and 
      (
        this = extractionCall
        or
        exists(API::CallNode contextClosingCallNode |
          contextClosingCallNode = API::moduleImport("contextlib").getMember("closing").getACall() and 
          this = contextClosingCallNode and 
          contextClosingCallNode.getArg(0) = extractionCall
        )
      )
    )
  }
}

/**
 * An enhanced taint tracking configuration for detecting TarSlip vulnerabilities
 */
private module TarSlipEnhancedFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode = tarfileExtractionOperation().getACall() 
  }

  predicate isSink(DataFlow::Node sinkNode) {
    exists(TarfileExtractionCall tarfileExtraction |
      // Case 1: extractall without members parameter
      exists(MethodCallNode extractAllMethodCall |
        extractAllMethodCall = tarfileExtraction.getReturn().getMember("extractall").getACall() and 
        not exists(Node arg | arg = extractAllMethodCall.getArgByName("members")) and 
        sinkNode = extractAllMethodCall.getObject()
      )
      or
      // Case 2: extractall with members parameter
      exists(MethodCallNode extractAllMethodCall, Node membersArg |
        extractAllMethodCall = tarfileExtraction.getReturn().getMember("extractall").getACall() and 
        membersArg = extractAllMethodCall.getArgByName("members") and 
        (
          // Subcase 2.1: members is a constant (None or list) -> safe, but we still track the object as sink?
          (membersArg.asCfgNode() instanceof NameConstantNode or 
           membersArg.asCfgNode() instanceof ListNode) and 
          sinkNode = extractAllMethodCall.getObject()
          or
          // Subcase 2.2: members comes from getmembers call -> dangerous
          exists(MethodCallNode getMembersMethodCall |
            getMembersMethodCall = membersArg and 
            getMembersMethodCall.getMethodName() = "getmembers" and 
            sinkNode = getMembersMethodCall.getObject()
          )
          or
          // Subcase 2.3: members is an arbitrary expression (not constant and not getmembers) -> dangerous
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
      // Case 3: extract method's path parameter
      sinkNode = tarfileExtraction.getReturn().getMember("extract").getACall().getArg(0)
      or
      // Case 4: _extract_member method's name attribute access
      exists(MethodCallNode extractMemberMethodCall |
        extractMemberMethodCall = tarfileExtraction.getReturn().getMember("_extract_member").getACall() and 
        extractMemberMethodCall.getArg(1).(AttrRead).accesses(sinkNode, "name")
      )
    ) and
    not sinkNode.getScope().getLocation().getFile().inStdlib()
  }

  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    // Step 1: Flow from TarfileExtractionCall to getmembers method call
    exists(MethodCallNode getMembersCall |
      getMembersCall = targetNode and 
      getMembersCall.calls(sourceNode, "getmembers") and 
      sourceNode instanceof TarfileExtractionCall
    )
    or
    // Step 2: Flow through contextlib.closing wrapper
    exists(API::CallNode contextClosingCallNode |
      contextClosingCallNode = targetNode and 
      contextClosingCallNode = API::moduleImport("contextlib").getMember("closing").getACall() and 
      sourceNode = contextClosingCallNode.getArg(0) and 
      sourceNode = tarfileExtractionOperation().getReturn().getAValueReachableFromSource()
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking configuration for enhanced TarSlip vulnerability detection */
module TarSlipImprovFlow = TaintTracking::Global<TarSlipEnhancedFlowConfig>;

from TarSlipImprovFlow::PathNode source, TarSlipImprovFlow::PathNode sink
where TarSlipImprovFlow::flowPath(source, sink)
select sink, source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()