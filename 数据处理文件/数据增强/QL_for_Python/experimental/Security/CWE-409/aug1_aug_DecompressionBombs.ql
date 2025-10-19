/**
 * @name Decompression Bomb Vulnerability
 * @description Identifies potential decompression bomb attacks where uncontrolled input
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

// Import core Python analysis capabilities
import python
// Import specialized decompression bomb detection functionality
import experimental.semmle.python.security.DecompressionBomb
// Import path graph utilities for flow visualization
import BombsFlow::PathGraph

// Define source and sink nodes in the data flow graph
from BombsFlow::PathNode sourceNode, BombsFlow::PathNode sinkNode
// Validate that a complete data flow path exists from source to sink
where BombsFlow::flowPath(sourceNode, sinkNode)
// Output security finding with detailed context and flow information
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "This uncontrolled decompression operation originates from $@.", 
       sourceNode.getNode(),
       "untrusted user input that could cause excessive resource consumption"