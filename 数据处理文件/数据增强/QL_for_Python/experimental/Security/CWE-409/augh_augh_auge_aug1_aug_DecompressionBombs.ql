/**
 * @name Decompression Bomb Vulnerability Detection
 * @description Detects potential decompression bomb vulnerabilities when untrusted input
 *              is processed by decompression libraries without proper size restrictions
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
// Import specialized decompression bomb detection capabilities
import experimental.semmle.python.security.DecompressionBomb
// Import path graph utilities for vulnerability flow tracking
import BombsFlow::PathGraph

// Define vulnerability flow components:
// - maliciousInputSource: represents untrusted data entry points
// - decompressionTarget: represents decompression API calls
from 
    BombsFlow::PathNode maliciousInputSource, 
    BombsFlow::PathNode decompressionTarget

// Verify complete data flow exists from source to target
where BombsFlow::flowPath(maliciousInputSource, decompressionTarget)

// Generate security alert with flow details
select decompressionTarget.getNode(), 
       maliciousInputSource, 
       decompressionTarget, 
       "This decompression operation processes untrusted input from $@.", 
       maliciousInputSource.getNode(),
       "user-controlled input that may cause resource exhaustion"