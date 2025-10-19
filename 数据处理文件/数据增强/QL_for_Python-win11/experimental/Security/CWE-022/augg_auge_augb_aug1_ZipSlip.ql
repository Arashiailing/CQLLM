/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies insecure archive extraction where malicious paths with '..' 
 *              can escape the target directory, leading to unauthorized file writes.
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

// Find dangerous data flows from archive entries to file operations
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode
where 
  // Trace vulnerable path from archive entry to filesystem operation
  ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Report vulnerability with complete flow context
select sourceNode.getNode(), sourceNode, sinkNode,
  "This unsanitized archive entry (possibly containing '../') reaches a $@.", sinkNode.getNode(),
  "file system operation"