/**
 * @name Predictable token
 * @description Tokens used for sensitive tasks (e.g., password recovery, email confirmation) 
 * should not be generated from predictable values like UUID versions 1, 3, or 5.
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

// Represents sources that produce predictable values (UUID v1/v3/v5 outputs)
class PredictableValueSource extends DataFlow::Node {
  PredictableValueSource() {
    exists(API::Node uuidApiCall |
      uuidApiCall = API::moduleImport("uuid").getMember(["uuid1", "uuid3", "uuid5"]).getReturn()
      |
      this = uuidApiCall.asSource()
      or
      this = uuidApiCall.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// Represents sinks where tokens/codes are assigned to sensitive variables
class TokenAssignmentSink extends DataFlow::Node {
  TokenAssignmentSink() {
    exists(string pattern | pattern.toLowerCase().matches(["%token", "%code"]) |
      exists(DefinitionNode defNode | 
        defNode.getValue() = this.asCfgNode() and 
        pattern = defNode.(NameNode).getId()
      )
      or
      exists(DataFlow::AttrWrite attrWrite | 
        attrWrite.getValue() = this and 
        pattern = attrWrite.getAttributeName()
      )
    )
  }
}

// Configuration for taint tracking analysis of token generation
private module TokenGenerationConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof PredictableValueSource 
  }

  predicate isSink(DataFlow::Node sink) { 
    sink instanceof TokenAssignmentSink 
  }

  predicate isAdditionalFlowStep(DataFlow::Node prevNode, DataFlow::Node nextNode) {
    exists(DataFlow::CallCfgNode strCall |
      strCall = API::builtin("str").getACall() and
      prevNode = strCall.getArg(0) and
      nextNode = strCall
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking for detecting tokens built from predictable UUIDs */
module PredictableTokenFlow = TaintTracking::Global<TokenGenerationConfig>;

import PredictableTokenFlow::PathGraph

from PredictableTokenFlow::PathNode source, PredictableTokenFlow::PathNode sink
where PredictableTokenFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Token built from $@.", source.getNode(), "predictable value"