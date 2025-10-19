/**
 * @name Timing Attack Vulnerability in Hash Verification
 * @description Identifies timing attack risks in cryptographic hash verification.
 *              Non-constant-time comparisons allow attackers to forge valid hashes
 *              through timing side-channels when submitting verification requests.
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
 * Configuration for tracking data flow from cryptographic operations
 * to timing-vulnerable equality comparisons.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  // Cryptographic operation outputs as data flow sources
  predicate isSource(DataFlow::Node cryptoOutput) { 
    cryptoOutput instanceof ProduceCryptoCall 
  }

  // Non-constant-time comparisons as data flow sinks
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }
}

// Global taint tracking configuration
module TimingAttackFlow = TaintTracking::Global<TimingAttackFlowConfig>;

import TimingAttackFlow::PathGraph

// Query to detect timing attack paths from crypto operations to user-influenced comparisons
from TimingAttackFlow::PathNode cryptoSource, TimingAttackFlow::PathNode vulnerableComparison
where
  // Data flow path exists between cryptographic operation and comparison
  TimingAttackFlow::flowPath(cryptoSource, vulnerableComparison) and
  // Comparison operation involves user-controllable input
  vulnerableComparison.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  vulnerableComparison.getNode(), 
  cryptoSource, 
  vulnerableComparison, 
  "Timing attack against $@ validation.", 
  cryptoSource.getNode().(ProduceCryptoCall).getResultType(), 
  "message"