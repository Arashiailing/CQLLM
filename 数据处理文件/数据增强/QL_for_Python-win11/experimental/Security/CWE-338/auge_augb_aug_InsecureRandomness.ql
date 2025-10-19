/**
 * @name Insecure randomness vulnerability
 * @description Identifies usage of cryptographically weak pseudo-random number generators
 *              for security-sensitive operations, potentially allowing attackers to
 *              predict generated values and compromise security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import core Python analysis framework for code examination
import python

// Import specialized security analysis module for detecting insecure random number patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow tracking framework to analyze value propagation through code
import semmle.python.dataflow.new.DataFlow

// Import path visualization module for representing data flow between sources and sinks
import InsecureRandomness::Flow::PathGraph

// Primary query logic: Identify insecure random value flows from generation to usage
// insecureSource: Origin point of cryptographically weak random value generation
// securitySink: Security-sensitive context where the insecure value is consumed
from InsecureRandomness::Flow::PathNode insecureSource, InsecureRandomness::Flow::PathNode securitySink
where InsecureRandomness::Flow::flowPath(insecureSource, securitySink) // Verify data flow connection exists
select securitySink.getNode(), insecureSource, securitySink, "Cryptographically insecure $@ used in security-sensitive context.",
  insecureSource.getNode(), "random value generation" // Output format: sink location, source, path, and alert details