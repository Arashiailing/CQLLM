/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects insecure archive extraction where malicious paths containing '..' 
 *              can bypass the target directory, potentially enabling unauthorized file 
 *              access outside the intended extraction location.
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

// Identify vulnerable flows from archive entry to filesystem operation
from ZipSlipFlow::PathNode entryNode, ZipSlipFlow::PathNode fsOpNode 
where ZipSlipFlow::flowPath(entryNode, fsOpNode)

// Generate alert with path traversal details
select entryNode.getNode(), entryNode, fsOpNode,
  "This unsanitized archive entry, potentially containing '..', is used in a $@.", fsOpNode.getNode(),
  "filesystem operation"