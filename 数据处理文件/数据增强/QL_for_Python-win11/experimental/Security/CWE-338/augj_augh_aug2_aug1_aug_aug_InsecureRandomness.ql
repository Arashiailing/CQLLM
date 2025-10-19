/**
 * @name Insecure randomness
 * @description Detects security-sensitive operations that use cryptographically weak 
 *              pseudo-random number generators, potentially allowing attackers to 
 *              predict generated values and compromise system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Fundamental Python analysis framework
import python

// Security analysis module focused on identifying weak random number generation
import experimental.semmle.python.security.InsecureRandomness

// Utilities for tracking and propagating data flow
import semmle.python.dataflow.new.DataFlow

// Framework for visualizing data flow paths
import InsecureRandomness::Flow::PathGraph

// Query for identifying and reporting insecure random value flows
from 
  InsecureRandomness::Flow::PathNode weakRandomSource,  // Origin of the insecure random value
  InsecureRandomness::Flow::PathNode sensitiveSink       // Security-sensitive endpoint where the value is used
where 
  // Check the data flow connection from the weak random source to the sensitive sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, sensitiveSink)
select 
  // Location of the insecure value usage (main result)
  sensitiveSink.getNode(),
  // Path visualization: source
  weakRandomSource,
  // Path visualization: sink
  sensitiveSink,
  // Security alert message referencing the vulnerable component
  "Cryptographically insecure $@ used in security context.",
  // Node referenced in the alert for context
  weakRandomSource.getNode(),
  // Brief description of the security issue
  "random value generation"