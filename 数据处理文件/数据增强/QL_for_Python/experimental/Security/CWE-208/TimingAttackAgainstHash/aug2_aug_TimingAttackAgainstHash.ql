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
 * Configuration module for tracking data flow from cryptographic operations
 * to timing-vulnerable equality comparisons.
 */
private module HashTimingAttackConfig implements DataFlow::ConfigSig {
  // Identify cryptographic operation outputs as data flow sources
  predicate isSource(DataFlow::Node cryptoOrigin) { 
    cryptoOrigin instanceof ProduceCryptoCall 
  }

  // Identify non-constant-time comparisons as data flow sinks
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }
}

// Global taint tracking module using the configuration
module HashTimingAttackFlow = TaintTracking::Global<HashTimingAttackConfig>;

import HashTimingAttackFlow::PathGraph

// Query to identify timing attack paths involving user input
from HashTimingAttackFlow::PathNode originNode, HashTimingAttackFlow::PathNode targetNode
where
  // Data flow path exists from cryptographic operation to comparison
  HashTimingAttackFlow::flowPath(originNode, targetNode) and
  // Comparison operation involves user-controllable input
  targetNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  targetNode.getNode(), 
  originNode, 
  targetNode, 
  "Timing attack against $@ validation.", 
  originNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"