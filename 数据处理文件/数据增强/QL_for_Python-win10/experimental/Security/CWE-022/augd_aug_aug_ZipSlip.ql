/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Detects unsafe archive extraction operations lacking proper path validation.
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

// Specialized security analysis module for detecting Zip Slip vulnerabilities
import experimental.semmle.python.security.ZipSlip

// Graph representation for tracking data flow in archive extraction scenarios
import ZipSlipFlow::PathGraph

// Identify vulnerable data flow paths from archive entries to file operations
from 
  ZipSlipFlow::PathNode sourceNode, 
  ZipSlipFlow::PathNode sinkNode
where 
  // Verify data flow path exists between untrusted archive entry and unsafe operation
  ZipSlipFlow::flowPath(sourceNode, sinkNode)
select 
  // The origin of untrusted archive entry data
  sourceNode.getNode(), 
  // Path visualization components for vulnerability tracking
  sourceNode, sinkNode,
  // Detailed vulnerability description
  "This unvalidated archive entry, potentially containing path traversal sequences like '..', is used in a $@.", 
  sinkNode.getNode(),
  "potentially unsafe file system operation"