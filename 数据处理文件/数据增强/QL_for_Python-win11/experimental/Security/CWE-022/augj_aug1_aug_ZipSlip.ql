/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects archive extraction vulnerabilities where path validation is missing,
 *              enabling attackers to access arbitrary files via malicious archives
 *              containing traversal sequences (e.g., '../').
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Core Python analysis infrastructure
import python

// Specialized ZipSlip vulnerability detection utilities
import experimental.semmle.python.security.ZipSlip

// Path propagation tracking framework
import ZipSlipFlow::PathGraph

// Identify vulnerable paths from archive entries to unsafe file operations
from 
  ZipSlipFlow::PathNode entrySource,      // Source: unvalidated archive entry
  ZipSlipFlow::PathNode fileOpSink        // Sink: insecure file system operation
where 
  ZipSlipFlow::flowPath(entrySource, fileOpSink)  // Data flow path exists

// Generate vulnerability report with contextual details
select 
  entrySource.getNode(),                  // Source location of tainted entry
  entrySource,                            // Source path node
  fileOpSink,                             // Sink path node
  "This unvalidated archive entry (potentially containing '../' sequences) reaches a $@.", 
  fileOpSink.getNode(),                   // Sink location
  "file system write operation"