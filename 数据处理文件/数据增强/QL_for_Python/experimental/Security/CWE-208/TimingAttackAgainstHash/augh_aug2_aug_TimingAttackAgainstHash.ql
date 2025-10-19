/**
 * @name Timing attack against Hash
 * @description Detects potential timing vulnerabilities in hash verification processes.
 *              Non-constant-time comparisons enable attackers to forge valid message hashes
 *              through timing analysis when they can submit verification requests.
 *              Successful exploitation may result in authentication bypass.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/timing-attack-against-hash
 * @tags security
 *       external/cwe/cwe-208
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configures data flow tracking from cryptographic operations (sources)
 * to non-constant-time comparisons (sinks) for timing attack detection.
 */
private module HashTimingFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof ProduceCryptoCall 
  }

  predicate isSink(DataFlow::Node sinkNode) { 
    sinkNode instanceof NonConstantTimeComparisonSink 
  }
}

module HashTimingFlow = TaintTracking::Global<HashTimingFlowConfig>;
import HashTimingFlow::PathGraph

/**
 * Identifies timing attack paths where cryptographic outputs
 * are compared using non-constant-time operations involving user input.
 */
from HashTimingFlow::PathNode sourcePathNode, HashTimingFlow::PathNode sinkPathNode
where
  HashTimingFlow::flowPath(sourcePathNode, sinkPathNode) and
  sinkPathNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  sinkPathNode.getNode(), 
  sourcePathNode, 
  sinkPathNode, 
  "Timing attack against $@ validation.", 
  sourcePathNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"