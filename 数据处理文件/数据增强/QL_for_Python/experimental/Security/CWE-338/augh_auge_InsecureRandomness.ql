/**
 * @name Insecure randomness
 * @description Identifies the use of cryptographically weak pseudo-random number generators
 *              in security-sensitive contexts, which allows attackers to predict generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import core Python analysis capabilities
import python

// Import specialized module for detecting insecure randomness patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow tracking functionality
import semmle.python.dataflow.new.DataFlow

// Import path graph representation for analyzing security flows
import InsecureRandomness::Flow::PathGraph

// This query traces data flows from insecure random number sources
// to security-sensitive contexts where they could be exploited
from InsecureRandomness::Flow::PathNode weakRandomSource, 
     InsecureRandomness::Flow::PathNode securityCriticalSink
where 
  // There exists a data flow path connecting the weak random source
  // to the security-critical sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, securityCriticalSink)
select 
  securityCriticalSink.getNode(),
  weakRandomSource,
  securityCriticalSink,
  "Cryptographically insecure $@ used in security-sensitive context.",
  weakRandomSource.getNode(),
  "random value"