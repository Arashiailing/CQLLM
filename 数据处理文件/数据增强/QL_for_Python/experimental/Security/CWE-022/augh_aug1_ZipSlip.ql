/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies unsafe archive extraction scenarios where malicious paths containing '..' 
 *              can circumvent directory constraints, enabling unauthorized file system access.
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

// Define source and sink nodes for path tracking
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode sinkNode

// Establish data flow between archive entry and file operation
where ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Generate vulnerability report with path context
select sourceNode.getNode(), sourceNode, sinkNode,
  "This unsanitized archive entry (potentially containing '..') is used in a $@.", sinkNode.getNode(),
  "file system operation"