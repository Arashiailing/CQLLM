/**
 * @name Predictable token generation
 * @description Tokens for security operations (e.g., password resets, email verification) 
 * should not derive from predictable values like UUID versions 1/3/5.
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

// Represents sources generating predictable UUID values
class PredictableSource extends DataFlow::Node {
  PredictableSource() {
    exists(API::Node uuidResult |
      uuidResult = API::moduleImport("uuid").getMember(["uuid1", "uuid3", "uuid5"]).getReturn()
    |
      this = uuidResult.asSource()
      or
      this = uuidResult.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// Represents sinks where security tokens are assigned
class TokenSink extends DataFlow::Node {
  TokenSink() {
    exists(string varName | varName.toLowerCase().matches(["%token", "%code"]) |
      exists(DefinitionNode defNode | defNode.getValue() = this.asCfgNode() | varName = defNode.(NameNode).getId())
      or
      exists(DataFlow::AttrWrite attrWrite | attrWrite.getValue() = this | varName = attrWrite.getAttributeName())
    )
  }
}

// Configuration for taint tracking of predictable tokens
private module UuidTokenFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { sourceNode instanceof PredictableSource }

  predicate isSink(DataFlow::Node sinkNode) { sinkNode instanceof TokenSink }

  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    exists(DataFlow::CallCfgNode call |
      call = API::builtin("str").getACall() and
      fromNode = call.getArg(0) and
      toNode = call
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint-tracking for UUID-derived security tokens */
module UuidTokenFlow = TaintTracking::Global<UuidTokenFlowConfig>;

import UuidTokenFlow::PathGraph

from UuidTokenFlow::PathNode sourceNode, UuidTokenFlow::PathNode sinkNode
where UuidTokenFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode, "Token derived from $@.", sourceNode.getNode(), "predictable value"