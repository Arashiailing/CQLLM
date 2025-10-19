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

// Identify vulnerable data flow paths from archive entries to file operations
from 
  ZipSlipFlow::PathNode sourceNode,  // Represents the archive entry source
  ZipSlipFlow::PathNode sinkNode      // Represents the file operation sink
where 
  // Verify data flow exists between source and sink nodes
  ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Report vulnerability with path context and operation details
select 
  sourceNode.getNode(), 
  sourceNode, 
  sinkNode,
  "This unsanitized archive entry, which may contain '..', is used in a $@.", 
  sinkNode.getNode(),
  "file system operation"