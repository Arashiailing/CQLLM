/**
 * @name Decompression Bomb
 * @description Uncontrolled data that flows into decompression library APIs without checking the compression rate is dangerous
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
// Import path graph for data flow analysis
import BombsFlow::PathGraph

// Identify vulnerable data flow paths
from BombsFlow::PathNode sourceNode, BombsFlow::PathNode sinkNode
where BombsFlow::flowPath(sourceNode, sinkNode)
// Select sink location with source context and warning message
select sinkNode.getNode(), sourceNode, sinkNode, "This uncontrolled file extraction is $@.", sourceNode.getNode(),
  "depends on this user controlled data"