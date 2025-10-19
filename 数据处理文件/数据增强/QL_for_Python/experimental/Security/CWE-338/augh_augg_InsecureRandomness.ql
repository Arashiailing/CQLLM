/**
 * @name Cryptographically weak randomness usage
 * @description Identifies security-sensitive operations that rely on 
 *              cryptographically insecure pseudo-random number generators,
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

// Core Python language support for analysis
import python

// Data flow tracking modules for vulnerability detection
import semmle.python.dataflow.new.DataFlow
import InsecureRandomness::Flow::PathGraph

// Security analysis module for identifying insecure random number generation
import experimental.semmle.python.security.InsecureRandomness

// Query to trace data flow from weak random sources to security-sensitive sinks
from InsecureRandomness::Flow::PathNode weakRandomSource, InsecureRandomness::Flow::PathNode sensitiveUsage
where InsecureRandomness::Flow::flowPath(weakRandomSource, sensitiveUsage)
select sensitiveUsage.getNode(), 
       weakRandomSource, 
       sensitiveUsage, 
       "Cryptographically insecure $@ used in security-sensitive context.",
       weakRandomSource.getNode(), 
       "random value"