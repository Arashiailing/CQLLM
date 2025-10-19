/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies archive extraction vulnerabilities where unvalidated paths
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

// Import core Python language analysis capabilities
import python

// Import specialized vulnerability detection for unsafe archive extraction
import experimental.semmle.python.security.ZipSlip

// Import path tracking graph for analyzing archive extraction data flows
import ZipSlipFlow::PathGraph

// Define source and sink variables for data flow analysis
from 
  ZipSlipFlow::PathNode untrustedArchiveEntry,
  ZipSlipFlow::PathNode vulnerableExtractionPoint
where 
  // Check if there's a data flow path from the untrusted archive entry to the vulnerable extraction point
  ZipSlipFlow::flowPath(untrustedArchiveEntry, vulnerableExtractionPoint)
select 
  // Output the source node representing the untrusted archive entry
  untrustedArchiveEntry.getNode(), 
  // Include the complete vulnerability path for visualization
  untrustedArchiveEntry, vulnerableExtractionPoint,
  // Provide a contextual vulnerability description
  "This unvalidated archive entry (potentially containing '../' sequences) is used in a $@.", 
  // Highlight the sink node in the description
  vulnerableExtractionPoint.getNode(),
  "unsafe file system operation"