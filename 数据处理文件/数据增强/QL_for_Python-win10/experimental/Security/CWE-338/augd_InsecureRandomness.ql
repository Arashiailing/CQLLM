/**
 * @name Insecure randomness
 * @description Detects security-sensitive values generated using cryptographically weak 
 *              pseudo-random number generators, which could allow prediction of generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python language support
import python

// Specialized module for detecting insecure random number generation
import experimental.semmle.python.security.InsecureRandomness

// Data flow analysis framework for tracking value propagation
import semmle.python.dataflow.new.DataFlow

// Path graph representation for data flow visualization
import InsecureRandomness::Flow::PathGraph

// Identify insecure random value flows to security-sensitive contexts
from InsecureRandomness::Flow::PathNode insecureRandomSource, 
     InsecureRandomness::Flow::PathNode securitySensitiveSink
where InsecureRandomness::Flow::flowPath(insecureRandomSource, securitySensitiveSink)
select securitySensitiveSink.getNode(), 
       insecureRandomSource, 
       securitySensitiveSink, 
       "Cryptographically insecure $@ in a security context.",
       insecureRandomSource.getNode(), 
       "random value"