/**
 * @name Decompression Bomb Vulnerability
 * @description Detects decompression bomb attacks where untrusted input flows into
 *              decompression APIs without compression rate validation
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

// Identify vulnerability source and sink points
from BombsFlow::PathNode vulnerabilitySource, BombsFlow::PathNode vulnerabilitySink
// Verify complete data flow path exists
where BombsFlow::flowPath(vulnerabilitySource, vulnerabilitySink)
// Generate security alert with flow context
select vulnerabilitySink.getNode(), 
       vulnerabilitySource, 
       vulnerabilitySink, 
       "This uncontrolled decompression originates from $@.", 
       vulnerabilitySource.getNode(),
       "untrusted input that may trigger excessive resource consumption"