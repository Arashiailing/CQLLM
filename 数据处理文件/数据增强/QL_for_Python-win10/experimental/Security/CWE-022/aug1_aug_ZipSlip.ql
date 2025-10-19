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

// Core Python analysis modules
import python

// Experimental ZipSlip vulnerability detection framework
import experimental.semmle.python.security.ZipSlip

// Path tracking infrastructure for data flow analysis
import ZipSlipFlow::PathGraph

// Identify vulnerable data flow paths from archive entry to file operations
from 
  ZipSlipFlow::PathNode taintedSource,   // Source: unsanitized archive entry
  ZipSlipFlow::PathNode dangerousSink    // Sink: unsafe file system operation
where 
  ZipSlipFlow::flowPath(taintedSource, dangerousSink)  // Path exists between source and sink

// Generate results with vulnerability context
select 
  taintedSource.getNode(),                // Vulnerability source location
  taintedSource,                          // Source path node
  dangerousSink,                          // Sink path node
  "This unsanitized archive entry (which may contain path traversal like '..') reaches a $@.", 
  dangerousSink.getNode(),               // Sink location
  "file system write operation"