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

// Trace vulnerable data flow from archive entry to file system operation
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode
where ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Report vulnerability with complete path context
select sourceNode.getNode(), sourceNode, sinkNode,
  "This unsanitized archive entry (potentially containing '..') flows to a $@.", sinkNode.getNode(),
  "file system operation"