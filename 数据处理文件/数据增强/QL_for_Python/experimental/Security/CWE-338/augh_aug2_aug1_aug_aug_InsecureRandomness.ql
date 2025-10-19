/**
 * @name Insecure randomness
 * @description Identifies security-sensitive operations that rely on cryptographically weak 
 *              pseudo-random number generators, enabling attackers to predict generated 
 *              values and compromise system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python analysis infrastructure
import python

// Security analysis module specialized for detecting weak random number generation
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking and propagation utilities
import semmle.python.dataflow.new.DataFlow

// Visualization framework for data flow paths
import InsecureRandomness::Flow::PathGraph

// Query to detect and report insecure random value flows
from 
  InsecureRandomness::Flow::PathNode insecureRandomOrigin,  // Starting point of insecure random value
  InsecureRandomness::Flow::PathNode sensitiveUsagePoint     // Security-critical destination of the value
where 
  // Verify data flow connection between insecure random source and sensitive sink
  InsecureRandomness::Flow::flowPath(insecureRandomOrigin, sensitiveUsagePoint)
select 
  // Location where insecure value is used (primary result)
  sensitiveUsagePoint.getNode(),
  // Path visualization: source node
  insecureRandomOrigin,
  // Path visualization: sink node
  sensitiveUsagePoint,
  // Security alert message with reference to vulnerable element
  "Cryptographically insecure $@ used in security context.",
  // Reference node for alert context
  insecureRandomOrigin.getNode(),
  // Description of the security issue
  "random value generation"