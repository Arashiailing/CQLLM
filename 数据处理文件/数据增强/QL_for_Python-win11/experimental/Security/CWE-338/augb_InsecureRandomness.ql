/**
 * @name Insecure randomness
 * @description Detects the use of cryptographically weak pseudo-random number generators
 *              for generating security-sensitive values, which could allow attackers
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

// Core imports for Python analysis
import python

// Security-specific imports for insecure randomness detection
import experimental.semmle.python.security.InsecureRandomness

// Data flow analysis imports
import semmle.python.dataflow.new.DataFlow
import InsecureRandomness::Flow::PathGraph

// Define query to find path problems related to insecure random number generation
from InsecureRandomness::Flow::PathNode insecureRandomSource, 
     InsecureRandomness::Flow::PathNode securitySensitiveSink
where InsecureRandomness::Flow::flowPath(insecureRandomSource, securitySensitiveSink)
select securitySensitiveSink.getNode(), 
       insecureRandomSource, 
       securitySensitiveSink, 
       "Cryptographically insecure $@ in a security context.",
       insecureRandomSource.getNode(), 
       "random value"