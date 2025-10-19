/**
 * @name Insecure randomness
 * @description Detects security-sensitive operations utilizing cryptographically weak 
 *              pseudo-random number generators, which may enable attackers to predict 
 *              generated values and compromise system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python analysis capabilities
import python

// Specialized security module for detecting insecure randomness patterns
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking framework
import semmle.python.dataflow.new.DataFlow

// Path graph visualization components
import InsecureRandomness::Flow::PathGraph

// Query identifies data flows from weak random sources to security-sensitive contexts
from 
  InsecureRandomness::Flow::PathNode insecureRandomSource,   // Origin of insecure random value
  InsecureRandomness::Flow::PathNode sensitiveUsagePoint     // Security-critical usage point
where 
  // Verify data flow path exists between source and sink
  InsecureRandomness::Flow::flowPath(insecureRandomSource, sensitiveUsagePoint)
select 
  sensitiveUsagePoint.getNode(),                      // Target location of insecure usage
  insecureRandomSource,                                // Origin node for path tracking
  sensitiveUsagePoint,                                // Sink node for visualization
  "Cryptographically insecure $@ in security context.", // Alert description
  insecureRandomSource.getNode(),                     // Reference node for alert message
  "random value"                                      // Description of vulnerable element