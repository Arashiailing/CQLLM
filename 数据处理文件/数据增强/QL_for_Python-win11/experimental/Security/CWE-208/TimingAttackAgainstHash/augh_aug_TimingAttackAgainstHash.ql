/**
 * @name Timing Attack Vulnerability in Hash Verification
 * @description Detects potential timing attacks during hash verification processes.
 *              Non-constant-time comparisons enable attackers to infer valid message hashes
 *              through response time analysis when submitting verification requests.
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
 * Configuration module for tracking data flow from cryptographic operations
 * to timing-vulnerable equality comparisons.
 */
private module HashTimingAttackConfig implements DataFlow::ConfigSig {
  // Identify non-constant-time comparisons as vulnerable sinks
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }

  // Identify cryptographic operation outputs as data flow sources
  predicate isSource(DataFlow::Node cryptoOutput) { 
    cryptoOutput instanceof ProduceCryptoCall 
  }
}

// Global taint tracking module based on the configuration
module HashTimingAttackFlow = TaintTracking::Global<HashTimingAttackConfig>;

import HashTimingAttackFlow::PathGraph

// Query to detect timing attack paths involving user-controllable inputs
from HashTimingAttackFlow::PathNode sourceNode, HashTimingAttackFlow::PathNode sinkNode
where
  // Verify sink involves user-controllable input
  sinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput() and
  // Confirm data flow path exists from source to sink
  HashTimingAttackFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Timing attack vulnerability in $@ validation.", 
  sourceNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"