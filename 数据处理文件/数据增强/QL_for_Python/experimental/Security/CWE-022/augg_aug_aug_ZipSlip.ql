/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects archive extraction operations lacking proper path validation. 
 *              Attackers can exploit this by crafting archives with path traversal 
 *              sequences (e.g., '../') to access files outside the target directory.
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

// Specialized security analysis module for Zip Slip vulnerability detection
import experimental.semmle.python.security.ZipSlip

// Graph representation for tracking data flow in archive extraction scenarios
import ZipSlipFlow::PathGraph

// Identify vulnerable data flow paths between untrusted sources and unsafe sinks
from 
  ZipSlipFlow::PathNode untrustedSource, 
  ZipSlipFlow::PathNode unsafeSink
where 
  // Verify data flow path exists from untrusted archive entry to file operation
  ZipSlipFlow::flowPath(untrustedSource, unsafeSink)
select 
  // Origin point of unvalidated archive entry
  untrustedSource.getNode(), 
  // Path visualization elements for vulnerability flow
  untrustedSource, 
  unsafeSink,
  // Detailed vulnerability explanation
  "This unvalidated archive entry (potentially containing path traversal sequences like '../') is used in a $@.", 
  unsafeSink.getNode(),
  "potentially unsafe file system operation"