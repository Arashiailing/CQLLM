/**
 * @name Decompression Bomb Vulnerability
 * @description Identifies decompression bomb vulnerabilities where untrusted input
 *              reaches decompression APIs without compression rate validation
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// Core Python analysis capabilities
import python
// Decompression bomb detection utilities
import experimental.semmle.python.security.DecompressionBomb
// Path flow visualization tools
import BombsFlow::PathGraph

// Define vulnerability source and sink components
from 
  BombsFlow::PathNode untrustedSource,  // Origin of untrusted input
  BombsFlow::PathNode decompressionSink // Target decompression API

// Validate complete data flow path exists
where 
  BombsFlow::flowPath(untrustedSource, decompressionSink)

// Generate security alert with flow context
select 
  decompressionSink.getNode(), 
  untrustedSource, 
  decompressionSink, 
  "This uncontrolled decompression originates from $@.", 
  untrustedSource.getNode(),
  "untrusted input that may trigger excessive resource consumption"