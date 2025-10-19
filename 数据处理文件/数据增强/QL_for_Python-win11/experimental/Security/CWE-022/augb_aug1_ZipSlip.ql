/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies unsafe archive extraction where malicious file paths containing '..' 
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

// Trace vulnerable data flows from archive entry to file operation
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode
where ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Generate vulnerability report with complete path context
select sourceNode.getNode(), sourceNode, sinkNode,
  "This unsanitized archive entry (potentially containing '..') flows to a $@.", sinkNode.getNode(),
  "file system operation"