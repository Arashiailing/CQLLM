/**
 * @name Timing attack against Hash
 * @description Identifies potential timing vulnerabilities in hash verification processes.
 *              Non-constant-time comparisons allow attackers to forge valid message hashes
 *              through timing analysis when they can submit verification requests.
 *              Successful exploitation may lead to authentication bypass.
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
 * Configuration module for tracking data flow from cryptographic operations
 * to non-constant-time comparisons, enabling timing attack detection.
 */
private module CryptoTimingFlowConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node originNode) { 
    originNode instanceof ProduceCryptoCall 
  }

  predicate isSink(DataFlow::Node targetNode) { 
    targetNode instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * Global taint tracking module for identifying timing attack paths
 * from cryptographic sources to vulnerable comparison sinks.
 */
module CryptoTimingFlow = TaintTracking::Global<CryptoTimingFlowConfiguration>;
import CryptoTimingFlow::PathGraph

/**
 * Detects timing attack vulnerabilities where cryptographic outputs
 * are compared using non-constant-time operations that involve user input.
 */
from CryptoTimingFlow::PathNode originPathNode, CryptoTimingFlow::PathNode targetPathNode
where
  CryptoTimingFlow::flowPath(originPathNode, targetPathNode) and
  targetPathNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  targetPathNode.getNode(), 
  originPathNode, 
  targetPathNode, 
  "Timing attack against $@ validation.", 
  originPathNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"