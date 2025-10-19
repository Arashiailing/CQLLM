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

// Identify vulnerable path flows from archive entry to file operation
from ZipSlipFlow::PathNode entryNode, ZipSlipFlow::PathNode operationNode
where ZipSlipFlow::flowPath(entryNode, operationNode)

// Report vulnerability details with path context
select entryNode.getNode(), entryNode, operationNode,
  "This unsanitized archive entry, which may contain '..', is used in a $@.", operationNode.getNode(),
  "file system operation"