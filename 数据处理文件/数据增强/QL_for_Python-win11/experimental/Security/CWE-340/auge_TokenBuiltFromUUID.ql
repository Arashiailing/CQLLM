/**
 * @name Predictable token generation
 * @description Tokens used for security-sensitive operations (e.g., password resets,
 *  email verification) must not derive from predictable values.
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

// Represents sources generating predictable values
class PredictableValueSource extends DataFlow::Node {
  PredictableValueSource() {
    exists(API::Node uuidResult |
      uuidResult = API::moduleImport("uuid").getMember(["uuid1", "uuid3", "uuid5"]).getReturn()
    |
      this = uuidResult.asSource()
      or
      this = uuidResult.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// Represents sinks where tokens are assigned
class TokenValueSink extends DataFlow::Node {
  TokenValueSink() {
    exists(string varName | varName.toLowerCase().matches(["%token", "%code"]) |
      exists(DefinitionNode defNode | defNode.getValue() = this.asCfgNode() | varName = defNode.(NameNode).getId())
      or
      exists(DataFlow::AttrWrite attrWrite | attrWrite.getValue() = this | varName = attrWrite.getAttributeName())
    )
  }
}

// Configuration for taint tracking analysis
private module TokenFromUuidConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) { src instanceof PredictableValueSource }

  predicate isSink(DataFlow::Node snk) { snk instanceof TokenValueSink }

  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    exists(DataFlow::CallCfgNode call |
      call = API::builtin("str").getACall() and
      fromNode = call.getArg(0) and
      toNode = call
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint-tracking for detecting tokens derived from predictable UUIDs */
module TokenFromUuidFlow = TaintTracking::Global<TokenFromUuidConfig>;

import TokenFromUuidFlow::PathGraph

from TokenFromUuidFlow::PathNode source, TokenFromUuidFlow::PathNode sink
where TokenFromUuidFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Token derived from $@.", source.getNode(), "predictable value"