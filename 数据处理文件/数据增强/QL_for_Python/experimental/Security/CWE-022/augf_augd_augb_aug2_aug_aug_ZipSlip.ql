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

// Import path tracking graph for archive extraction data flows
import ZipSlipFlow::PathGraph

// Define variables representing the source (untrusted archive entry) and sink (vulnerable extraction operation)
from 
  ZipSlipFlow::PathNode untrustedArchiveEntry,
  ZipSlipFlow::PathNode vulnerableExtractionOperation
where 
  // Verify that a data flow path exists between the untrusted archive entry and the extraction operation
  exists(ZipSlipFlow::PathNode pathSource, ZipSlipFlow::PathNode pathSink |
    pathSource = untrustedArchiveEntry and
    pathSink = vulnerableExtractionOperation and
    ZipSlipFlow::flowPath(pathSource, pathSink)
  )
select 
  // Source node representing the untrusted archive entry
  untrustedArchiveEntry.getNode(), 
  // Complete vulnerability path visualization from source to sink
  untrustedArchiveEntry, vulnerableExtractionOperation,
  // Contextual vulnerability description with sink details
  "This unvalidated archive entry (potentially containing '../' sequences) is used in a $@.", 
  vulnerableExtractionOperation.getNode(),
  "unsafe file system operation"