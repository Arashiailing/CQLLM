/**
 * @name Insecure randomness
 * @description Identifies security risks when cryptographically weak pseudo-random number generators
 *              are used for security-sensitive operations, allowing attackers to predict values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python analysis libraries
import python

// Specialized module for detecting insecure randomness patterns
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking framework
import semmle.python.dataflow.new.DataFlow

// Path graph representation for security-sensitive flows
import InsecureRandomness::Flow::PathGraph

// Query identifying flows from weak random sources to security-sensitive sinks
from InsecureRandomness::Flow::PathNode weakRandomSource, 
     InsecureRandomness::Flow::PathNode securityCriticalSink
where 
  // Data flow path exists between weak random source and security-critical sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, securityCriticalSink)
select 
  securityCriticalSink.getNode(),
  weakRandomSource,
  securityCriticalSink,
  "Cryptographically insecure $@ used in security-sensitive context.",
  weakRandomSource.getNode(),
  "random value"