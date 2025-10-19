/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects unsafe archive extraction where malicious file paths containing '..' 
 *              can circumvent directory restrictions, leading to unauthorized 
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
from ZipSlipFlow::PathNode taintedEntryNode, ZipSlipFlow::PathNode fileOpNode
where 
  // Trace the complete flow path from source to sink
  ZipSlipFlow::flowPath(taintedEntryNode, fileOpNode)

// Generate vulnerability report with full path context
select 
  taintedEntryNode.getNode(), 
  taintedEntryNode, 
  fileOpNode,
  "This unsanitized archive entry (potentially containing '..') flows to a $@.", 
  fileOpNode.getNode(),
  "file system operation"