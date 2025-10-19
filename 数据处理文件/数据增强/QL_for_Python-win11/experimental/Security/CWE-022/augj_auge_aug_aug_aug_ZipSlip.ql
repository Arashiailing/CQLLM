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

// Identify vulnerable data flows from archive entries to file operations
from 
  ZipSlipFlow::PathNode sourceNode,   // Source node representing untrusted archive entry
  ZipSlipFlow::PathNode sinkNode      // Sink node representing dangerous file operation

// Verify data flows from untrusted archive entry to dangerous file operation
where 
  ZipSlipFlow::flowPath(sourceNode, sinkNode)

// Report vulnerability with source/sink context and explanation
select 
  sourceNode.getNode(),    // Source node for alert location
  sourceNode,              // Source node for path visualization
  sinkNode,                // Sink node for path visualization
  "This unsanitized archive entry (possibly containing '../') reaches a $@.", 
  sinkNode.getNode(),      // Sink node for message context
  "file system operation"