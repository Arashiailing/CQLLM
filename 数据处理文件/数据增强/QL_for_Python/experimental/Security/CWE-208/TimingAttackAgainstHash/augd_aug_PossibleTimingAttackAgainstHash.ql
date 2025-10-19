/**
 * @name Hash Verification Timing Vulnerability
 * @description Message hash verification should use constant-time algorithms.
 *              Attackers can forge valid hashes by analyzing response time differences,
 *              potentially bypassing authentication mechanisms.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-against-hash
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

// Global taint tracking module configuration
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // Source: Cryptographic operation calls (e.g., hash generation)
  predicate isSource(DataFlow::Node cryptographicOperation) { 
    cryptographicOperation instanceof ProduceCryptoCall 
  }

  // Sink: Non-constant-time comparison operations
  predicate isSink(DataFlow::Node comparisonOperation) { 
    comparisonOperation instanceof NonConstantTimeComparisonSink 
  }
}

// Initialize global taint tracking with the configuration
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;
import TimingAttackFlow::PathGraph

// Main query logic: Detect potential timing attack vulnerability paths
from
  TimingAttackFlow::PathNode cryptoSourceNode,    // Source node representing cryptographic operation
  TimingAttackFlow::PathNode comparisonSinkNode    // Sink node representing comparison operation
where 
  TimingAttackFlow::flowPath(cryptoSourceNode, comparisonSinkNode)
select 
  comparisonSinkNode.getNode(), 
  cryptoSourceNode, 
  comparisonSinkNode, 
  "Timing attack vulnerability on $@ verification",
  cryptoSourceNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"