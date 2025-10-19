/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies insecure archive extraction operations that allow malicious paths with '..' 
 *              to escape the intended extraction directory, potentially leading to unauthorized 
 *              file writes or reads outside the target location.
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

// Trace vulnerable flows from archive entry to file system operation
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode 
where ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Generate alert with path details
select sourceNode.getNode(), sourceNode, sinkNode,
  "This unsanitized archive entry, which may contain '..', is used in a $@.", sinkNode.getNode(),
  "file system operation"