/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies vulnerabilities in archive extraction where insufficient path validation
 *              enables attackers to bypass directory restrictions using path traversal sequences
 *              like '..' within maliciously crafted archive files.
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

// Define source and sink nodes for vulnerability detection
from 
  ZipSlipFlow::PathNode maliciousArchiveEntry, 
  ZipSlipFlow::PathNode unsafeExtractionPoint
where 
  // Establish data flow relationship between archive entry and extraction
  ZipSlipFlow::flowPath(maliciousArchiveEntry, unsafeExtractionPoint)
select 
  // Source of the vulnerability - untrusted archive entry
  maliciousArchiveEntry.getNode(), 
  // Complete data flow path for vulnerability visualization
  maliciousArchiveEntry, unsafeExtractionPoint,
  // Detailed vulnerability description with context
  "This unvalidated archive entry (potentially containing '../' sequences) is used in a $@.", 
  unsafeExtractionPoint.getNode(),
  "vulnerable file system operation"