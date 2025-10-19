/**
 * @name Predictable token
 * @description Tokens used for sensitive tasks (e.g., password recovery, 
 * email confirmation) should not use predictable values from UUID generation.
 * @kind path-problem
 * @precision medium
 * @problem.severity error
 * @security-severity 5
 * @id py/predictable-token
 * @tags security
 *       experimental
 *       external/cwe/cwe-340
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking

// Represents sources of predictable values from UUID generation methods
class PredictableValueSource extends DataFlow::Node {
  PredictableValueSource() {
    exists(API::Node uuidMethodReturn |
      // Identify predictable UUID generation methods
      uuidMethodReturn = API::moduleImport("uuid")
        .getMember(["uuid1", "uuid3", "uuid5"])
        .getReturn()
    |
      // Direct return values from UUID methods
      this = uuidMethodReturn.asSource()
      or
      // Derived values (hex/bytes representations)
      this = uuidMethodReturn.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// Represents sinks where tokens are assigned to sensitive variables
class TokenAssignmentSink extends DataFlow::Node {
  TokenAssignmentSink() {
    exists(string sensitiveName | 
      sensitiveName.toLowerCase().matches(["%token", "%code"])
    |
      // Variable assignments with sensitive names
      exists(DefinitionNode defNode | 
        defNode.getValue() = this.asCfgNode() | 
        sensitiveName = defNode.(NameNode).getId()
      )
      or
      // Attribute assignments with sensitive names
      exists(DataFlow::AttrWrite attrWrite | 
        attrWrite.getValue() = this | 
        sensitiveName = attrWrite.getAttributeName()
      )
    )
  }
}

// Configuration for taint tracking analysis of token generation
private module TokenFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof PredictableValueSource 
  }

  predicate isSink(DataFlow::Node sink) { 
    sink instanceof TokenAssignmentSink 
  }

  // Additional flow step for string conversion
  predicate isAdditionalFlowStep(DataFlow::Node inputNode, DataFlow::Node outputNode) {
    exists(DataFlow::CallCfgNode strCall |
      strCall = API::builtin("str").getACall() and
      inputNode = strCall.getArg(0) and
      outputNode = strCall
    )
  }

  // Enable differential incremental analysis
  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking for token predictability vulnerabilities */
module TokenFlowAnalysis = TaintTracking::Global<TokenFlowConfig>;

import TokenFlowAnalysis::PathGraph

// Query: Detect paths from predictable sources to token assignments
from TokenFlowAnalysis::PathNode source, TokenFlowAnalysis::PathNode sink
where TokenFlowAnalysis::flowPath(source, sink)
select sink.getNode(), source, sink, "Token built from $@.", source.getNode(), "predictable value"