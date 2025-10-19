/**
 * @name Path traversal vulnerability in tarball extraction from untrusted sources
 * @description Extracting archives from user-controlled inputs without sanitizing 
 *              file paths may enable writing files outside the target directory.
 *              This occurs when tarballs are derived from untrusted origins,
 *              including network sources or user-provided arguments.
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

// Identify vulnerable data flow paths from untrusted inputs to archive extraction points
from UnsafeUnpackFlow::PathNode maliciousInput, UnsafeUnpackFlow::PathNode vulnerableExtraction
where UnsafeUnpackFlow::flowPath(maliciousInput, vulnerableExtraction)
select vulnerableExtraction.getNode(), maliciousInput, vulnerableExtraction,
  "Path traversal via unsanitized archive extraction from untrusted origin"