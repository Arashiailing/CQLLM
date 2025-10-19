/**
 * @name Insecure randomness vulnerability
 * @description Identifies usage of cryptographically weak random number generators
 *              in security-sensitive contexts, potentially allowing prediction of values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import base Python analysis constructs
import python

// Import specialized detection logic for insecure randomness patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis framework for tracking value propagation
import semmle.python.dataflow.new.DataFlow

// Import path graph utilities for visualizing data flow between nodes
import InsecureRandomness::Flow::PathGraph

// Define variables representing the start and end of the insecure data flow
from InsecureRandomness::Flow::PathNode insecureRandomSource, 
     InsecureRandomness::Flow::PathNode securityContextSink

// Ensure a data flow path exists between the insecure source and security-sensitive sink
where InsecureRandomness::Flow::flowPath(insecureRandomSource, securityContextSink)

// Generate results with the sink node, source node, path, and alert message
select securityContextSink.getNode(), 
       insecureRandomSource, 
       securityContextSink, 
       "Cryptographically insecure $@ in a security context.",
       insecureRandomSource.getNode(), 
       "random value"