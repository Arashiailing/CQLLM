/**
 * @name Predictable token
 * @description Tokens used for sensitive tasks, such as password recovery
 *  and email confirmation, should not use predictable values.
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

// Represents sources of predictable values from UUID generation
class PredictableResultSource extends DataFlow::Node {
  PredictableResultSource() {
    exists(API::Node uuidMethod |
      // Identify predictable UUID generation methods
      uuidMethod = API::moduleImport("uuid")
        .getMember(["uuid1", "uuid3", "uuid5"])
        .getReturn()
    |
      // Direct return values from UUID methods
      this = uuidMethod.asSource()
      or
      // Access to UUID attributes (hex, bytes, bytes_le)
      this = uuidMethod.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// Represents sinks where tokens are assigned to sensitive variables
class TokenAssignmentValueSink extends DataFlow::Node {
  TokenAssignmentValueSink() {
    exists(string tokenName | 
      // Match token-related variable names
      tokenName.toLowerCase().matches(["%token", "%code"])
    |
      // Variable assignments with token names
      exists(DefinitionNode defNode | 
        defNode.getValue() = this.asCfgNode() and 
        tokenName = defNode.(NameNode).getId()
      )
      or
      // Attribute assignments with token names
      exists(DataFlow::AttrWrite attrWrite | 
        attrWrite.getValue() = this and 
        tokenName = attrWrite.getAttributeName()
      )
    )
  }
}

// Configuration for taint tracking analysis of token generation
private module TokenBuiltFromUuidConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof PredictableResultSource 
  }

  predicate isSink(DataFlow::Node sink) { 
    sink instanceof TokenAssignmentValueSink 
  }

  // Additional flow step for string conversion
  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    exists(DataFlow::CallCfgNode strCall |
      // Track flow through str() function calls
      strCall = API::builtin("str").getACall() and
      nodeFrom = strCall.getArg(0) and
      nodeTo = strCall
    )
  }

  // Enable differential analysis mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint-tracking for detecting token generation from predictable UUIDs */
module TokenBuiltFromUuidFlow = TaintTracking::Global<TokenBuiltFromUuidConfig>;

import TokenBuiltFromUuidFlow::PathGraph

// Query to detect token generation from predictable UUIDs
from TokenBuiltFromUuidFlow::PathNode source, TokenBuiltFromUuidFlow::PathNode sink
where TokenBuiltFromUuidFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Token built from $@.", source.getNode(), "predictable value"