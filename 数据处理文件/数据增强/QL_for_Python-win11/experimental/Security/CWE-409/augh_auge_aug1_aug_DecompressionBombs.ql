/**
 * @name Decompression Bomb Vulnerability
 * @description Identifies potential decompression bomb vulnerabilities where untrusted data
 *              is processed by decompression APIs without adequate size limits
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// Import necessary modules for Python security analysis
import python
// Import specialized module for detecting decompression bomb vulnerabilities
import experimental.semmle.python.security.DecompressionBomb
// Import path graph utilities for tracking data flow paths
import BombsFlow::PathGraph

// Define the source and sink for vulnerability detection
from BombsFlow::PathNode untrustedSource, BombsFlow::PathNode decompressionSink
// Ensure there is a complete data flow path from source to sink
where BombsFlow::flowPath(untrustedSource, decompressionSink)
// Generate alert with detailed flow information
select decompressionSink.getNode(), 
       untrustedSource, 
       decompressionSink, 
       "This decompression operation processes untrusted input from $@.", 
       untrustedSource.getNode(),
       "user-controlled input that may cause resource exhaustion"