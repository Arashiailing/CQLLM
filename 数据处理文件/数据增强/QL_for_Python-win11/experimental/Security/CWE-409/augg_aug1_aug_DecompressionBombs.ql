/**
 * @name Decompression Bomb Vulnerability
 * @description Detects potential decompression bomb vulnerabilities where untrusted input
 *              reaches decompression APIs without proper compression ratio validation
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// Core Python analysis framework
import python
// Specialized decompression bomb detection capabilities
import experimental.semmle.python.security.DecompressionBomb
// Path visualization utilities for data flow tracking
import BombsFlow::PathGraph

// Identify vulnerable decompression paths
from BombsFlow::PathNode untrustedSource, BombsFlow::PathNode decompressionTarget
// Verify complete data flow path exists from untrusted source to decompression sink
where BombsFlow::flowPath(untrustedSource, decompressionTarget)
// Report vulnerability with flow context and source details
select decompressionTarget.getNode(), 
       untrustedSource, 
       decompressionTarget, 
       "This unsafe decompression operation originates from $@.", 
       untrustedSource.getNode(),
       "uncontrolled input that may trigger resource exhaustion"