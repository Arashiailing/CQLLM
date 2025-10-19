/**
 * @name Path traversal vulnerability in tarball extraction from untrusted sources
 * @description Detects path traversal vulnerabilities that occur when extracting archives 
 *              from user-controlled inputs without proper path sanitization. This allows 
 *              attackers to write files outside the intended extraction directory, potentially 
 *              leading to system compromise. The vulnerability manifests when tarballs 
 *              originate from untrusted sources such as network inputs or user-provided arguments.
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

// Define source and sink nodes for tracking dangerous unpacking operations
from UnsafeUnpackFlow::PathNode untrustedInput, UnsafeUnpackFlow::PathNode vulnerableExtraction

// Establish data flow path from untrusted input to vulnerable extraction point
where UnsafeUnpackFlow::flowPath(untrustedInput, vulnerableExtraction)

// Generate alert with complete flow context for the identified vulnerability
select vulnerableExtraction.getNode(), untrustedInput, vulnerableExtraction,
  "Path traversal via unsanitized archive extraction from untrusted origin"