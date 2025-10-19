/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies insecure archive extraction where malicious paths with '..' 
 *              can escape the target directory, potentially enabling unauthorized 
 *              file system access outside the intended extraction location.
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

// Identify vulnerable data flow paths from archive entry to file system operation
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode 
where ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Generate security alert with complete path details
select sourceNode.getNode(), sourceNode, sinkNode,
  "This unsanitized archive entry (potentially containing '..') flows to a $@.", sinkNode.getNode(),
  "file system operation"