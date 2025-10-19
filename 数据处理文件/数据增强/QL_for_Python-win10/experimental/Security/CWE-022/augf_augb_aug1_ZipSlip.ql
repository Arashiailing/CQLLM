/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects unsafe archive extraction where malicious file paths containing '..' 
 *              can bypass destination directory restrictions, enabling unauthorized 
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

// Identify vulnerable data flow paths from archive entry to file operation
from ZipSlipFlow::PathNode archiveEntryNode, ZipSlipFlow::PathNode fileOperationNode
where ZipSlipFlow::flowPath(archiveEntryNode, fileOperationNode)

// Generate vulnerability report with complete path context
select archiveEntryNode.getNode(), archiveEntryNode, fileOperationNode,
  "This unsanitized archive entry (potentially containing '..') flows to a $@.", fileOperationNode.getNode(),
  "file system operation"