/**
 * @name Decompression Bomb Vulnerability
 * @description Detects decompression bomb attacks where untrusted input reaches 
 *              decompression APIs without compression ratio validation
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
// Specialized decompression bomb detection module
import experimental.semmle.python.security.DecompressionBomb
// Path graph utilities for security flow visualization
import BombsFlow::PathGraph

// Identify vulnerable decompression paths
from BombsFlow::PathNode userInputOrigin, BombsFlow::PathNode decompressionTarget
// Verify complete data flow from untrusted input to decompression operation
where BombsFlow::flowPath(userInputOrigin, decompressionTarget)
// Report vulnerability with attack path details
select decompressionTarget.getNode(), 
       userInputOrigin, 
       decompressionTarget, 
       "This decompression operation processes $@ without size validation.", 
       userInputOrigin.getNode(),
       "untrusted input that may trigger resource exhaustion"