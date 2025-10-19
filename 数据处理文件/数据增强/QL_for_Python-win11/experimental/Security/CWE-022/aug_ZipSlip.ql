/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Extracting files from a malicious ZIP file, or similar type of archive, without
 *              validating that the destination file path is within the destination directory
 *              can allow an attacker to unexpectedly gain access to resources.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// Import required Python analysis modules
import python

// Import experimental security analysis for ZipSlip vulnerability detection
import experimental.semmle.python.security.ZipSlip

// Import path graph for tracking file path propagation
import ZipSlipFlow::PathGraph

// Identify path flow between vulnerable source and sink nodes
from ZipSlipFlow::PathNode entryPoint, ZipSlipFlow::PathNode operationPoint
where ZipSlipFlow::flowPath(entryPoint, operationPoint)

// Select results with vulnerability context
select entryPoint.getNode(), entryPoint, operationPoint,
  "This unsanitized archive entry (which may contain path traversal like '..') reaches a $@.", 
  operationPoint.getNode(), 
  "file system write operation"