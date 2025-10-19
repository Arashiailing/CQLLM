/**
 * @name Decompression Bomb Vulnerability
 * @description Detects decompression bomb vulnerabilities where untrusted data
 *              is processed by decompression APIs without proper size restrictions
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// Import core Python analysis modules
import python
// Import specialized decompression bomb detection utilities
import experimental.semmle.python.security.DecompressionBomb
// Import path tracking infrastructure for data flow analysis
import BombsFlow::PathGraph

// Identify malicious input sources and vulnerable decompression operations
from BombsFlow::PathNode maliciousInput, BombsFlow::PathNode decompressionOperation
// Verify complete data flow path exists between source and sink
where BombsFlow::flowPath(maliciousInput, decompressionOperation)
// Generate vulnerability report with detailed flow information
select decompressionOperation.getNode(), 
       maliciousInput, 
       decompressionOperation, 
       "Decompression operation processes untrusted input from $@.", 
       maliciousInput.getNode(),
       "potentially malicious input that could trigger resource exhaustion"