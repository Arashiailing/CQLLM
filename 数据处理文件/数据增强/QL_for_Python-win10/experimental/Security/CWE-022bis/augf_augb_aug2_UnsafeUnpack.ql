/**
 * @name Path traversal vulnerability in tarball extraction from untrusted sources
 * @description Extracting archives without sanitizing file paths from untrusted sources 
 *              (e.g., network sources or user-provided arguments) can lead to writing files 
 *              outside the target directory, resulting in a path traversal vulnerability.
 * @kind path-problem
 * @id py/unsafe-unpacking
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import experimental.Security.UnsafeUnpackQuery
import UnsafeUnpackFlow::PathGraph

// Define data flow components for vulnerability detection
from 
  UnsafeUnpackFlow::PathNode maliciousInput,  // Untrusted data entry point
  UnsafeUnpackFlow::PathNode extractionTarget  // Vulnerable extraction operation
// Establish tainted data flow path between components
where 
  UnsafeUnpackFlow::flowPath(maliciousInput, extractionTarget)
// Report vulnerability with complete flow context
select 
  extractionTarget.getNode(), 
  maliciousInput, 
  extractionTarget,
  "Path traversal via unsanitized archive extraction from untrusted origin"