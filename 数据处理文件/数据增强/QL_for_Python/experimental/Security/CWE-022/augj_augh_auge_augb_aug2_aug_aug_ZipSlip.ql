/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies security weaknesses in archive extraction procedures where
 *              insufficient path validation enables attackers to bypass directory
 *              constraints using path traversal sequences like '..' embedded
 *              within maliciously crafted archive files.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Core Python language analysis infrastructure
import python

// Specialized library for detecting unsafe archive extraction vulnerabilities
import experimental.semmle.python.security.ZipSlip

// Path traversal graph for monitoring data flows in archive extraction activities
import ZipSlipFlow::PathGraph

from 
  // Origin point representing the unverified archive entry
  ZipSlipFlow::PathNode maliciousArchiveEntry,
  // Destination point representing the susceptible extraction operation
  ZipSlipFlow::PathNode insecureExtractionPoint
where 
  // Establish data flow connection between archive entry and extraction location
  ZipSlipFlow::flowPath(maliciousArchiveEntry, insecureExtractionPoint)
select 
  // Vulnerability source - the unauthenticated archive entry
  maliciousArchiveEntry.getNode(), 
  // Complete data flow trajectory for vulnerability visualization and investigation
  maliciousArchiveEntry, insecureExtractionPoint,
  // Detailed vulnerability description explaining the security risk
  "This unverified archive entry (possibly containing '../' patterns) is utilized in a $@.", 
  insecureExtractionPoint.getNode(),
  "vulnerable file system operation"