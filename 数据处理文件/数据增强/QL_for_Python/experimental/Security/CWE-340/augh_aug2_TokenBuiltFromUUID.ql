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

// Identifies sources generating predictable values (UUID methods)
class PredictableValueSource extends DataFlow::Node {
  PredictableValueSource() {
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

// Identifies sinks where tokens are assigned to sensitive variables
class SensitiveTokenSink extends DataFlow::Node {
  SensitiveTokenSink() {
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

// Taint tracking configuration for predictable token analysis
private module PredictableTokenFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof PredictableValueSource 
  }

  predicate isSink(DataFlow::Node sink) { 
    sink instanceof SensitiveTokenSink 
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

// Global taint-tracking module for detecting tokens from predictable UUIDs
module PredictableTokenTaintFlow = TaintTracking::Global<PredictableTokenFlowConfig>;

import PredictableTokenTaintFlow::PathGraph

from PredictableTokenTaintFlow::PathNode source, PredictableTokenTaintFlow::PathNode sink
where PredictableTokenTaintFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Token built from $@.", source.getNode(), "predictable value"