/**
 * @name Insecure randomness
 * @description Identifies security-sensitive operations that employ 
 *              cryptographically weak pseudo-random number generators,
 *              enabling adversaries to predict generated values and 
 *              compromise system integrity.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python language analysis framework
import python

// Security analysis module for detecting weak random number generation patterns
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking and propagation analysis system
import semmle.python.dataflow.new.DataFlow

// Visualization components for security data flow paths
import InsecureRandomness::Flow::PathGraph

// Query definition for tracking insecure random value flows
from 
  InsecureRandomness::Flow::PathNode insecureRandomSource,   // Origin point of weak random generation
  InsecureRandomness::Flow::PathNode securityCriticalSink     // Security-sensitive operation consuming the value
where 
  // Establish data flow connection between source and sink
  InsecureRandomness::Flow::flowPath(insecureRandomSource, securityCriticalSink)
select 
  securityCriticalSink.getNode(),                         // Location of vulnerable usage
  insecureRandomSource,                                   // Path origin for analysis
  securityCriticalSink,                                   // Terminal node for path visualization
  "Cryptographically insecure $@ utilized in security-sensitive context.", // Vulnerability description
  insecureRandomSource.getNode(),                         // Reference point for alert highlighting
  "random value generation"                               // Component identification