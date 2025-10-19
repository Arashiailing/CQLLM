/**
 * @name Insecure randomness
 * @description Detects the use of cryptographically weak pseudo-random number generators
 *              for generating security-sensitive values, which could enable attackers
 *              to predict the generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python language support for analysis
import python

// Data flow tracking modules for vulnerability detection
import semmle.python.dataflow.new.DataFlow
import InsecureRandomness::Flow::PathGraph

// Security analysis module for identifying insecure random number generation
import experimental.semmle.python.security.InsecureRandomness

// Query to trace data flow from insecure random sources to security-sensitive sinks
from InsecureRandomness::Flow::PathNode insecureRandomSource, InsecureRandomness::Flow::PathNode securitySensitiveSink
where InsecureRandomness::Flow::flowPath(insecureRandomSource, securitySensitiveSink)
select securitySensitiveSink.getNode(), insecureRandomSource, securitySensitiveSink, 
       "Cryptographically insecure $@ in a security context.",
       insecureRandomSource.getNode(), "random value"