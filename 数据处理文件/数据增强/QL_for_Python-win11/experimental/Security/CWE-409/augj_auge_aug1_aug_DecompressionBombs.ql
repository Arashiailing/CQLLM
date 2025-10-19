/**
 * @name Decompression Bomb Vulnerability
 * @description Identifies potential decompression bomb vulnerabilities where 
 *              maliciously crafted compressed input can cause resource exhaustion
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
// Import path graph utilities for tracking vulnerability propagation
import BombsFlow::PathGraph

// Define the vulnerability flow components: malicious source and vulnerable sink
from BombsFlow::PathNode maliciousSource, BombsFlow::PathNode vulnerableSink
// Establish that a complete data flow path exists between source and sink
where BombsFlow::flowPath(maliciousSource, vulnerableSink)
// Generate vulnerability report with complete flow context and source attribution
select vulnerableSink.getNode(), 
       maliciousSource, 
       vulnerableSink, 
       "This decompression operation processes untrusted input from $@.", 
       maliciousSource.getNode(),
       "user-controlled input that may cause resource exhaustion"