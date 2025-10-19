/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects insecure archive extraction where paths containing '..' 
 *              can escape the target directory, enabling unauthorized file writes.
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

// Identify dangerous data flows originating from archive entries
// to file system operations vulnerable to path traversal
from ZipSlipFlow::PathNode entryNode, ZipSlipFlow::PathNode operationNode
where 
  // Trace vulnerable path from archive entry to filesystem operation
  ZipSlipFlow::flowPath(entryNode, operationNode)

// Report vulnerability with complete flow context
select entryNode.getNode(), entryNode, operationNode,
  "This unsanitized archive entry (potentially containing '../') reaches a $@.", operationNode.getNode(),
  "file system operation"