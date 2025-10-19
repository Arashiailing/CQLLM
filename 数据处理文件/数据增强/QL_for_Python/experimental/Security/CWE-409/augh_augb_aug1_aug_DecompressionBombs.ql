/**
 * @name Decompression Bomb Vulnerability
 * @description Identifies decompression bomb vulnerabilities where untrusted data
 *              is passed to decompression APIs without compression ratio checks
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

// Identify source and sink nodes for decompression attacks
from BombsFlow::PathNode sourceNode, BombsFlow::PathNode sinkNode
// Ensure complete data flow path exists between source and sink
where BombsFlow::flowPath(sourceNode, sinkNode)
// Generate security alert with complete attack path context
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "This uncontrolled decompression originates from $@.", 
       sourceNode.getNode(),
       "untrusted input that may trigger excessive resource consumption"