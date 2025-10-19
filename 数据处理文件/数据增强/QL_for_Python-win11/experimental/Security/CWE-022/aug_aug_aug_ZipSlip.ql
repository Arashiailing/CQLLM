/**
 * @name Path traversal vulnerability in archive extraction ("Zip Slip")
 * @description Identifies insecure archive extraction operations where paths 
 *              containing traversal sequences (e.g., '../') could enable 
 *              attackers to write files outside the target directory, 
 *              leading to unauthorized system access.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Import core Python analysis capabilities
import python

// Import specialized archive traversal vulnerability detection logic
import experimental.semmle.python.security.ZipSlip

// Import path tracking infrastructure for data flow visualization
import ZipSlipFlow::PathGraph

// Identify vulnerable data flows from archive entries to file operations
from ZipSlipFlow::PathNode sourceNode, ZipSlipFlow::PathNode targetNode

// Ensure data flows from untrusted archive entry to dangerous file access
where ZipSlipFlow::flowPath(sourceNode, targetNode)

// Report vulnerability with source/sink context and explanation
select sourceNode.getNode(), sourceNode, targetNode,
  "This unsanitized archive entry (possibly containing '../') reaches a $@.", targetNode.getNode(),
  "file system operation"