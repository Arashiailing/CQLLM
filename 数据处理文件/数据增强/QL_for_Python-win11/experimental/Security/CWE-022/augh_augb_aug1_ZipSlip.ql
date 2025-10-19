/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects insecure archive extraction allowing malicious paths with '..' 
 *              to escape target directory restrictions, enabling unauthorized 
 *              file system writes.
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

// Identify vulnerable data flows from archive entries to file operations
from ZipSlipFlow::PathNode entryNode, ZipSlipFlow::PathNode fileOpNode
where ZipSlipFlow::flowPath(entryNode, fileOpNode)

// Generate vulnerability report with complete path context
select entryNode.getNode(), entryNode, fileOpNode,
  "This unsanitized archive entry (potentially containing '..') flows to a $@.", fileOpNode.getNode(),
  "file system operation"