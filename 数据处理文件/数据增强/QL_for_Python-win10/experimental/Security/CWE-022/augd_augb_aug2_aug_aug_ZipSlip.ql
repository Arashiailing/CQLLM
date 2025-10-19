/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies archive extraction vulnerabilities where未经验证的路径
 *              could enable attackers to access files outside the target directory
 *              through archives containing path traversal sequences (e.g., '..').
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

// Declare source and sink variables for data flow analysis
from 
  ZipSlipFlow::PathNode maliciousArchiveEntry,
  ZipSlipFlow::PathNode unsafeExtractionPoint
where 
  // Verify data flow path exists between archive entry and extraction operation
  exists(ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink |
    source = maliciousArchiveEntry and
    sink = unsafeExtractionPoint and
    ZipSlipFlow::flowPath(source, sink)
  )
select 
  // Source node representing the untrusted archive entry
  maliciousArchiveEntry.getNode(), 
  // Complete vulnerability path visualization
  maliciousArchiveEntry, unsafeExtractionPoint,
  // Contextual vulnerability description
  "This未经验证的archive entry (potentially containing '../' sequences) is used in a $@.", 
  unsafeExtractionPoint.getNode(),
  "unsafe file system operation"