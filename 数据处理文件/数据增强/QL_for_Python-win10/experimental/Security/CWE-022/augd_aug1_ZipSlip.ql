/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects unsafe archive extraction where malicious file paths containing '..' 
 *              could bypass destination directory restrictions, leading to unauthorized 
 *              file system access.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph

// Identify vulnerable data flows from archive entry to file operation
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode
where 
  // Establish data flow path between archive entry and file operation
  ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Report vulnerability with path context and operation details
select 
  sourceNode.getNode(), 
  sourceNode, 
  sinkNode,
  "This unsanitized archive entry, which may contain '..', is used in a $@.", 
  sinkNode.getNode(),
  "file system operation"