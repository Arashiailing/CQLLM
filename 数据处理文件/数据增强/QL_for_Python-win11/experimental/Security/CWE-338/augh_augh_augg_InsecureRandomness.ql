/**
 * @name Weak cryptographic randomness vulnerability
 * @description Detects security-critical operations utilizing 
 *              cryptographically insecure pseudo-random number generators,
 *              which could allow attackers to predict generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Fundamental Python language analysis components
import python

// Data flow tracking framework for vulnerability detection
import semmle.python.dataflow.new.DataFlow
import InsecureRandomness::Flow::PathGraph

// Security analysis module for weak random number generation detection
import experimental.semmle.python.security.InsecureRandomness

// Query identifying data flow from insecure random sources to security-sensitive sinks
from InsecureRandomness::Flow::PathNode insecureRandomSource, InsecureRandomness::Flow::PathNode sensitiveSink
where InsecureRandomness::Flow::flowPath(insecureRandomSource, sensitiveSink)
select sensitiveSink.getNode(), 
       insecureRandomSource, 
       sensitiveSink, 
       "Cryptographically insecure $@ used in security-sensitive context.",
       insecureRandomSource.getNode(), 
       "random value"