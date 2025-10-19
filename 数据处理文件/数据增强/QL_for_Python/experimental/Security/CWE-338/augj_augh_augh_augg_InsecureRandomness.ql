/**
 * @name Weak cryptographic randomness vulnerability
 * @description Identifies security-sensitive operations that employ 
 *              cryptographically weak pseudo-random number generators,
 *              potentially enabling attackers to predict generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python language analysis infrastructure
import python

// Data flow analysis framework for security vulnerability detection
import semmle.python.dataflow.new.DataFlow
import InsecureRandomness::Flow::PathGraph

// Security analysis components for detecting weak random number generation
import experimental.semmle.python.security.InsecureRandomness

// Query that traces data flow from weak random sources to security-critical sinks
from InsecureRandomness::Flow::PathNode weakRandomSource, 
     InsecureRandomness::Flow::PathNode securityCriticalSink
where 
  // Establish data flow path between source and sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, securityCriticalSink)
select 
  // Primary result: the vulnerable sink location
  securityCriticalSink.getNode(), 
  // Source node in the data flow path
  weakRandomSource, 
  // Sink node in the data flow path
  securityCriticalSink, 
  // Warning message with source reference
  "Cryptographically insecure $@ used in security-sensitive context.",
  // Reference to the source node for message formatting
  weakRandomSource.getNode(), 
  // Label for the source node
  "random value"