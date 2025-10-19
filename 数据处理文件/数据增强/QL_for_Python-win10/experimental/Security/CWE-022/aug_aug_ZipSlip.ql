/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description This query identifies vulnerabilities where archive extraction is performed
 *              without proper path validation. Attackers can exploit this by crafting
 *              malicious archives with path traversal sequences (e.g., '..') to access
 *              files outside the intended extraction directory.
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

// Specialized security analysis module for detecting Zip Slip vulnerabilities
import experimental.semmle.python.security.ZipSlip

// Graph representation for tracking data flow in archive extraction scenarios
import ZipSlipFlow::PathGraph

// Define the vulnerability source and sink nodes
from 
  ZipSlipFlow::PathNode vulnerabilitySource, 
  ZipSlipFlow::PathNode vulnerableOperation
where 
  // Verify that a data flow path exists between the source and sink
  ZipSlipFlow::flowPath(vulnerabilitySource, vulnerableOperation)
select 
  // The source node where the untrusted archive path originates
  vulnerabilitySource.getNode(), 
  // Path visualization elements for the complete vulnerability flow
  vulnerabilitySource, vulnerableOperation,
  // Detailed vulnerability explanation message
  "This unvalidated archive entry, potentially containing path traversal sequences like '..', is used in a $@.", 
  vulnerableOperation.getNode(),
  "potentially unsafe file system operation"