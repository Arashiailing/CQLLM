/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects security vulnerabilities in archive extraction processes where
 *              inadequate path validation allows attackers to circumvent directory
 *              restrictions using path traversal sequences such as '..' embedded
 *              within specially crafted archive files.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Fundamental Python language analysis framework
import python

// Specialized module for identifying unsafe archive extraction vulnerabilities
import experimental.semmle.python.security.ZipSlip

// Path analysis graph for tracking data flows in archive extraction operations
import ZipSlipFlow::PathGraph

from 
  // Source node representing the untrusted archive entry
  ZipSlipFlow::PathNode untrustedArchiveSource, 
  // Sink node representing the vulnerable extraction operation
  ZipSlipFlow::PathNode vulnerableExtractionSink
where 
  // Establish data flow connection between archive entry and extraction point
  ZipSlipFlow::flowPath(untrustedArchiveSource, vulnerableExtractionSink)
select 
  // Vulnerability origin - the unvalidated archive entry
  untrustedArchiveSource.getNode(), 
  // Complete data flow path for vulnerability visualization and analysis
  untrustedArchiveSource, vulnerableExtractionSink,
  // Contextual vulnerability description highlighting the security issue
  "This unvalidated archive entry (potentially containing '../' sequences) is used in a $@.", 
  vulnerableExtractionSink.getNode(),
  "vulnerable file system operation"