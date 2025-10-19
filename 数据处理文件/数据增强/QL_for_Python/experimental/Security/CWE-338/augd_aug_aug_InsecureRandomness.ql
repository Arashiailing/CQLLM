/**
 * @name Insecure randomness
 * @description Identifies usage of cryptographically weak pseudo-random number generators
 *              in security-sensitive contexts, potentially enabling attackers to predict
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

// Import Python core library for code analysis capabilities
import python

// Import security module specialized in detecting weak random number patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow framework for tracking value propagation paths
import semmle.python.dataflow.new.DataFlow

// Import path graph module for visualizing data flow trajectories
import InsecureRandomness::Flow::PathGraph

// Query definition: Trace data flow from insecure random sources to security-sensitive sinks
from 
  InsecureRandomness::Flow::PathNode insecureSource,  // Origin point of weak random value
  InsecureRandomness::Flow::PathNode securitySink     // Security-critical usage point
where 
  // Validate existence of data flow path between source and sink
  InsecureRandomness::Flow::flowPath(insecureSource, securitySink)
select 
  securitySink.getNode(),                           // Target location of insecure value usage
  insecureSource,                                   // Origin point for path visualization
  securitySink,                                     // Sink point for path visualization
  "Cryptographically insecure $@ in security context.", // Alert message template
  insecureSource.getNode(),                         // Reference node for message context
  "random value"                                   // Description of vulnerable element