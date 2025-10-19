/**
 * @name Timing attack against Hash
 * @description Detects potential timing vulnerabilities when verifying message hashes.
 *              Constant-time algorithms must be used for hash verification to prevent
 *              attackers from forging valid hashes through runtime differences,
 *              which could lead to authentication bypass.
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
 * Configuration module for cryptographic timing attack analysis
 * Defines data flow sources (cryptographic operations) and sinks 
 * (non-constant time comparisons) for the analysis
 */
private module CryptoTimingAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * Source definition: Data nodes originating from cryptographic operations
   * Includes hash function calls and other operations that produce cryptographic values
   */
  predicate isSource(DataFlow::Node cryptoSourceNode) { 
    cryptoSourceNode instanceof ProduceCryptoCall 
  }

  /**
   * Sink definition: Non-constant time comparison operation nodes
   * These operations may leak sensitive information through execution time
   */
  predicate isSink(DataFlow::Node timingSinkNode) { 
    timingSinkNode instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * Global taint tracking module for cryptographic timing attacks
 * Tracks data flow paths from cryptographic operations to non-constant time comparisons
 */
module CryptoTimingAttackFlow = TaintTracking::Global<CryptoTimingAnalysisConfig>;

// Import path graph for path analysis
import CryptoTimingAttackFlow::PathGraph

/**
 * Main query: Detects timing attack paths in hash verification
 * Identifies data flow from cryptographic operations to non-constant time comparisons,
 * where the comparison involves user-controllable input
 */
from CryptoTimingAttackFlow::PathNode originPathNode, CryptoTimingAttackFlow::PathNode targetPathNode
where
  // Condition 1: Data flow path exists from cryptographic operation to comparison
  CryptoTimingAttackFlow::flowPath(originPathNode, targetPathNode) and
  // Condition 2: Comparison operation includes user input, expanding attack surface
  targetPathNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // Output format: sink node, source node, path nodes, description message, message type
  targetPathNode.getNode(), 
  originPathNode, 
  targetPathNode, 
  "Timing attack against $@ validation.",
  originPathNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"