/**
 * @name Decompression Bomb Vulnerability
 * @description Detects potential decompression bomb attacks where uncontrolled input
 *              flows into decompression APIs without proper compression rate checks
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
// Path graph utilities for visualizing data flows
import BombsFlow::PathGraph

// Identify vulnerable data flow paths
from BombsFlow::PathNode untrustedSource, BombsFlow::PathNode decompressionSink
// Verify complete data flow path exists from source to sink
where BombsFlow::flowPath(untrustedSource, decompressionSink)
// Report security finding with flow context
select decompressionSink.getNode(), 
       untrustedSource, 
       decompressionSink, 
       "This uncontrolled decompression operation originates from $@.", 
       untrustedSource.getNode(),
       "untrusted user input that could cause excessive resource consumption"