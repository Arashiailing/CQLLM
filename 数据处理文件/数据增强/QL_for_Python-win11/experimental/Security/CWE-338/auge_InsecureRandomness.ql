/**
 * @name Insecure randomness
 * @description Detects usage of cryptographically weak pseudo-random number generators
 *              for security-sensitive values, enabling attackers to predict generated values.
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

// Specialized module for insecure randomness detection
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking capabilities
import semmle.python.dataflow.new.DataFlow

// Path graph representation for security flows
import InsecureRandomness::Flow::PathGraph

// Query identifying insecure random value flows to security-sensitive contexts
from InsecureRandomness::Flow::PathNode insecureRandomSource, 
     InsecureRandomness::Flow::PathNode securitySensitiveSink
where 
  // Data flow path exists between insecure source and sensitive sink
  InsecureRandomness::Flow::flowPath(insecureRandomSource, securitySensitiveSink)
select 
  securitySensitiveSink.getNode(),
  insecureRandomSource,
  securitySensitiveSink,
  "Cryptographically insecure $@ used in security-sensitive context.",
  insecureRandomSource.getNode(),
  "random value"