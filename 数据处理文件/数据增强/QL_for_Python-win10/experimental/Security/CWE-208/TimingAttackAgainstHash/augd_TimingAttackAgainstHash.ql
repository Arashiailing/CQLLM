/**
 * @name Timing attack against Hash
 * @description Detects potential timing vulnerabilities when comparing hash values.
 *              Non-constant-time comparisons allow attackers to forge valid hashes
 *              through response time analysis, potentially bypassing authentication.
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
 * Configuration tracking data flow from cryptographic operations
 * to vulnerable equality comparisons.
 */
private module HashTimingAttackConfig implements DataFlow::ConfigSig {
  // Sources: Nodes producing cryptographic values
  predicate isSource(DataFlow::Node cryptoSource) { 
    cryptoSource instanceof ProduceCryptoCall 
  }

  // Sinks: Non-constant-time comparison operations
  predicate isSink(DataFlow::Node comparisonSink) { 
    comparisonSink instanceof NonConstantTimeComparisonSink 
  }
}

module HashTimingAttackFlow = TaintTracking::Global<HashTimingAttackConfig>;
import HashTimingAttackFlow::PathGraph

// Query to find vulnerable paths from crypto operations to comparisons
from HashTimingAttackFlow::PathNode cryptoSource, HashTimingAttackFlow::PathNode comparisonSink
where
  // Ensure data flows from cryptographic source to comparison sink
  HashTimingAttackFlow::flowPath(cryptoSource, comparisonSink) and
  // Verify sink involves user-controlled input
  comparisonSink.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // Maintain original output format with enhanced variable names
  comparisonSink.getNode(), 
  cryptoSource, 
  comparisonSink, 
  "Timing attack against $@ validation.",
  cryptoSource.getNode().(ProduceCryptoCall).getResultType(), 
  "message"