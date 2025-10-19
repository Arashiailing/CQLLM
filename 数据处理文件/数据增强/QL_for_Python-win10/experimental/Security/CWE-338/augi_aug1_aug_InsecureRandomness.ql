/**
 * @name Insecure randomness
 * @description Identifies security vulnerabilities where cryptographically weak 
 *              pseudo-random number generators are used to create security-sensitive values,
 *              enabling attackers to predict generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python analysis framework
import python

// Specialized module for detecting insecure random number generation patterns
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking framework for analyzing value propagation
import semmle.python.dataflow.new.DataFlow

// Path graph representation for visualizing data flow trajectories
import InsecureRandomness::Flow::PathGraph

// Identify data flow paths from insecure random sources to security-sensitive sinks
from InsecureRandomness::Flow::PathNode insecureRandomSource, InsecureRandomness::Flow::PathNode sensitiveUsage
// Verify data flow propagation between source and sink nodes
where InsecureRandomness::Flow::flowPath(insecureRandomSource, sensitiveUsage)
// Output results with sink node, source node, path details, and vulnerability description
select sensitiveUsage.getNode(), insecureRandomSource, sensitiveUsage, 
       "Cryptographically insecure $@ in security-sensitive context.",
       insecureRandomSource.getNode(), "random value"