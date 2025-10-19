/**
 * @name Decompression Bomb Vulnerability
 * @description Identifies uncontrolled data flowing into decompression APIs without proper compression ratio checks
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// Import Python analysis framework
import python
// Import experimental decompression bomb detection module
import experimental.semmle.python.security.DecompressionBomb
// Import data flow path graph utilities
import BombsFlow::PathGraph

// Define source and sink nodes for data flow analysis
from BombsFlow::PathNode sourceNode, BombsFlow::PathNode sinkNode
// Verify data flow path exists between source and sink
where BombsFlow::flowPath(sourceNode, sinkNode)
// Generate security alert with flow path details
select sinkNode.getNode(), sourceNode, sinkNode, 
  "This uncontrolled file extraction originates from $@.", 
  sourceNode.getNode(),
  "user-controlled input data"