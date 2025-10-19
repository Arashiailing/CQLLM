/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies vulnerabilities in archive extraction where unvalidated paths
 *              could enable attackers to access files outside the target directory via
 *              crafted archives containing path traversal sequences (e.g., '..').
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Core Python language analysis capabilities
import python

// Specialized vulnerability detection for unsafe archive extraction
import experimental.semmle.python.security.ZipSlip

// Path tracking graph for archive extraction data flows
import ZipSlipFlow::PathGraph

// Identify vulnerable data flow paths from untrusted archive entries
from 
  ZipSlipFlow::PathNode maliciousArchiveEntry, 
  ZipSlipFlow::PathNode unsafeExtractionOp
where 
  // Verify existence of data flow path between entry and operation
  ZipSlipFlow::flowPath(maliciousArchiveEntry, unsafeExtractionOp)
select 
  // Origin point of untrusted archive entry
  maliciousArchiveEntry.getNode(), 
  // Complete vulnerability path visualization
  maliciousArchiveEntry, unsafeExtractionOp,
  // Contextual vulnerability description
  "This unvalidated archive entry (potentially containing '../' sequences) is used in a $@.", 
  unsafeExtractionOp.getNode(),
  "vulnerable file system operation"