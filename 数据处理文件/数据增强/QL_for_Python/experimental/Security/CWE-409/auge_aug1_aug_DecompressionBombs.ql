/**
 * @name Decompression Bomb Vulnerability
 * @description Detects decompression bomb vulnerabilities where untrusted input 
 *              flows into decompression APIs without proper size validation
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// Import core Python analysis framework
import python
// Import specialized decompression bomb detection module
import experimental.semmle.python.security.DecompressionBomb
// Import path graph utilities for vulnerability flow tracking
import BombsFlow::PathGraph

// Define vulnerability flow endpoints: untrusted input source and decompression sink
from BombsFlow::PathNode untrustedInput, BombsFlow::PathNode decompressionOp
// Verify complete data flow path exists between source and sink
where BombsFlow::flowPath(untrustedInput, decompressionOp)
// Report vulnerability with full flow context and source attribution
select decompressionOp.getNode(), 
       untrustedInput, 
       decompressionOp, 
       "This decompression operation processes untrusted input from $@.", 
       untrustedInput.getNode(),
       "user-controlled input that may cause resource exhaustion"