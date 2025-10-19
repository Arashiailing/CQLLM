/**
 * @name Timing attack against Hash
 * @description Validates that constant-time algorithms are used when verifying message hashes.
 *              Non-constant-time comparisons allow attackers to forge valid message hashes
 *              through timing attacks if they can submit messages to the verification process.
 *              Successful exploitation could lead to authentication bypass.
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
 * Configuration module tracking data flow from cryptographic operations
 * to equality comparisons vulnerable to timing attacks.
 */
private module HashTimingAttackConfig implements DataFlow::ConfigSig {
  // Define cryptographic operation outputs as data flow sources
  predicate isSource(DataFlow::Node cryptoSource) { 
    cryptoSource instanceof ProduceCryptoCall 
  }

  // Define non-constant-time comparisons as data flow sinks
  predicate isSink(DataFlow::Node comparisonSink) { 
    comparisonSink instanceof NonConstantTimeComparisonSink 
  }
}

// Global taint tracking module using the configuration
module HashTimingAttackFlow = TaintTracking::Global<HashTimingAttackConfig>;

import HashTimingAttackFlow::PathGraph

// Query to identify timing attack paths involving user input
from HashTimingAttackFlow::PathNode pathSource, HashTimingAttackFlow::PathNode pathSink
where
  // Data flow path exists from cryptographic operation to comparison
  HashTimingAttackFlow::flowPath(pathSource, pathSink) and
  // Comparison operation involves user-controllable input
  pathSink.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  pathSink.getNode(), 
  pathSource, 
  pathSink, 
  "Timing attack against $@ validation.", 
  pathSource.getNode().(ProduceCryptoCall).getResultType(), 
  "message"