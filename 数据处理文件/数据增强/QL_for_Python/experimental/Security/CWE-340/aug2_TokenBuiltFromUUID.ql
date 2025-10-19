/**
 * @name Predictable token
 * @description Tokens used for sensitive tasks (e.g., password recovery,
 *  email confirmation) should not use predictable values.
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

// Represents sources generating predictable values (UUID methods)
class PredictableResultSource extends DataFlow::Node {
  PredictableResultSource() {
    exists(API::Node uuidMethodReturn |
      uuidMethodReturn = API::moduleImport("uuid")
        .getMember(["uuid1", "uuid3", "uuid5"])
        .getReturn()
    |
      this = uuidMethodReturn.asSource()
      or
      this = uuidMethodReturn.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// Represents sinks where tokens are assigned to sensitive variables
class TokenAssignmentValueSink extends DataFlow::Node {
  TokenAssignmentValueSink() {
    exists(string tokenNamePattern | 
      tokenNamePattern.toLowerCase().matches(["%token", "%code"])
    |
      exists(DefinitionNode defNode | 
        defNode.getValue() = this.asCfgNode() | 
        tokenNamePattern = defNode.(NameNode).getId()
      )
      or
      exists(DataFlow::AttrWrite attrWrite | 
        attrWrite.getValue() = this | 
        tokenNamePattern = attrWrite.getAttributeName()
      )
    )
  }
}

// Configuration for taint tracking analysis of predictable tokens
private module PredictableTokenConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof PredictableResultSource 
  }

  predicate isSink(DataFlow::Node sink) { 
    sink instanceof TokenAssignmentValueSink 
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

/** Global taint-tracking for detecting tokens built from predictable UUIDs */
module PredictableTokenFlow = TaintTracking::Global<PredictableTokenConfig>;

import PredictableTokenFlow::PathGraph

from PredictableTokenFlow::PathNode source, PredictableTokenFlow::PathNode sink
where PredictableTokenFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Token built from $@.", source.getNode(), "predictable value"