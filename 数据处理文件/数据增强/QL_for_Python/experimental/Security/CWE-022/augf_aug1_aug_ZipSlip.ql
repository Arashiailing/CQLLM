/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects vulnerabilities where archive extraction lacks path validation,
 *              allowing attackers to access arbitrary files via malicious archives
 *              containing path traversal sequences (e.g., '../').
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

// Import experimental framework for ZipSlip vulnerability detection
import experimental.semmle.python.security.ZipSlip

// Import path tracking infrastructure for data flow analysis
import ZipSlipFlow::PathGraph

// Query identifies vulnerable data flow paths from archive entries to file operations
// where path validation is missing, allowing potential directory traversal attacks
from ZipSlipFlow::PathNode unvalidatedEntry, ZipSlipFlow::PathNode unsafeFileOp
where ZipSlipFlow::flowPath(unvalidatedEntry, unsafeFileOp)

// Generate vulnerability results with source and sink context
select 
  unvalidatedEntry.getNode(),              // Vulnerability source location
  unvalidatedEntry,                        // Source path node
  unsafeFileOp,                            // Sink path node
  "This unsanitized archive entry (which may contain path traversal like '..') reaches a $@.", 
  unsafeFileOp.getNode(),                  // Sink location
  "file system write operation"