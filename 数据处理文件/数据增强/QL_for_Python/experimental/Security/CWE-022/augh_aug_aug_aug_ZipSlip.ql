/**
 * @name Path traversal vulnerability in archive extraction ("Zip Slip")
 * @description Detects unsafe archive extraction where paths with traversal 
 *              sequences (e.g., '../') allow attackers to write files outside 
 *              the target directory, potentially leading to system compromise.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Core Python analysis capabilities
import python

// Archive traversal vulnerability detection logic
import experimental.semmle.python.security.ZipSlip

// Path tracking infrastructure for data flow visualization
import ZipSlipFlow::PathGraph

// Identify vulnerable data flows from archive entries to file operations
from ZipSlipFlow::PathNode untrustedEntry, ZipSlipFlow::PathNode fileOperation

// Ensure data flows exist between untrusted archive entry and dangerous file access
where ZipSlipFlow::flowPath(untrustedEntry, fileOperation)

// Report vulnerability with source/sink context and explanation
select untrustedEntry.getNode(), untrustedEntry, fileOperation,
  "This unsanitized archive entry (potentially containing '../') reaches a $@.", fileOperation.getNode(),
  "file system operation"