/**
 * @name Decompression Bomb
 * @description Detects uncontrolled data flowing into decompression APIs without compression rate validation
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

// Identify source and target nodes in data flow paths
from BombsFlow::PathNode originNode, BombsFlow::PathNode targetNode
// Verify existence of data flow path between nodes
where BombsFlow::flowPath(originNode, targetNode)
// Generate security alert with contextual information
select targetNode.getNode(), originNode, targetNode, 
  "This uncontrolled file extraction is $@.", 
  originNode.getNode(),
  "depends on this user controlled data"