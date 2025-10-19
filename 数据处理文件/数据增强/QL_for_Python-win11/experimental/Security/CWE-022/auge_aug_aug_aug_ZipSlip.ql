/**
 * @name Archive extraction path traversal vulnerability ("Zip Slip")
 * @description Detects archive extraction code that fails to sanitize paths containing 
 *              traversal sequences (e.g., '../'), which could allow attackers to write 
 *              files outside the intended directory, potentially leading to unauthorized access.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Import core Python analysis modules
import python

// Import specialized logic for detecting archive traversal vulnerabilities
import experimental.semmle.python.security.ZipSlip

// Import path tracking infrastructure for visualizing data flows
import ZipSlipFlow::PathGraph

// Identify vulnerable data flows originating from archive entries to file operations
from 
  ZipSlipFlow::PathNode entryNode, 
  ZipSlipFlow::PathNode fileOpNode

// Verify that data flows from an untrusted archive entry to a dangerous file operation
where 
  ZipSlipFlow::flowPath(entryNode, fileOpNode)

// Report the vulnerability with source and sink context along with an explanation
select 
  entryNode.getNode(), 
  entryNode, 
  fileOpNode,
  "This unsanitized archive entry (possibly containing '../') reaches a $@.", 
  fileOpNode.getNode(),
  "file system operation"