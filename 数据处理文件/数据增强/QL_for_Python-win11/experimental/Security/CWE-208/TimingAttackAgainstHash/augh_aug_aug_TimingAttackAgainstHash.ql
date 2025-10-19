/**
 * @name Hash Timing Vulnerability Detector
 * @description This query identifies timing vulnerabilities when validating hash values.
 *              Using non-constant time algorithms for hash comparison can allow attackers
 *              to forge valid hashes for arbitrary messages through timing attacks.
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
 * Security Configuration Module: Tracks data flow from cryptographic operations
 * to non-constant time comparisons
 * This module defines sources and sinks for the data flow analysis
 */
private module HashTimingSecurityConfig implements DataFlow::ConfigSig {
  /**
   * Source definition: Nodes representing cryptographic operations
   * These nodes represent operations that produce cryptographic values,
   * such as hash function calls
   */
  predicate isSource(DataFlow::Node hashOperationNode) { 
    hashOperationNode instanceof ProduceCryptoCall 
  }

  /**
   * Sink definition: Nodes representing non-constant time comparison operations
   * These nodes represent comparison operations that may leak timing information
   */
  predicate isSink(DataFlow::Node nonConstantTimeCompNode) { 
    nonConstantTimeCompNode instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * Global taint tracking module based on the configuration
 * Used to track data flow from cryptographic operations to non-constant time comparisons
 */
module HashTimingVulnerabilityFlow = TaintTracking::Global<HashTimingSecurityConfig>;

// Import path graph for path analysis
import HashTimingVulnerabilityFlow::PathGraph

/**
 * Main query: Detects security risk paths
 * Finds data flow paths from cryptographic operations to non-constant time comparisons,
 * where the comparison operation includes user input, increasing the attack surface
 */
from HashTimingVulnerabilityFlow::PathNode hashSourceNode, HashTimingVulnerabilityFlow::PathNode timingVulnerableSinkNode
where
  // Condition 1: Data flow path exists from cryptographic operation to comparison operation
  HashTimingVulnerabilityFlow::flowPath(hashSourceNode, timingVulnerableSinkNode) and
  // Condition 2: Comparison operation includes user input, expanding the attack surface
  timingVulnerableSinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // Output format: Sink node, source node, path node, description, message type
  timingVulnerableSinkNode.getNode(), hashSourceNode, timingVulnerableSinkNode, "Timing attack against $@ validation.",
  hashSourceNode.getNode().(ProduceCryptoCall).getResultType(), "message"