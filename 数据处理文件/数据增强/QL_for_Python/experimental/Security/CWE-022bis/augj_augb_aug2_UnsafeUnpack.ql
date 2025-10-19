/**
 * @name Path traversal vulnerability in tarball extraction from untrusted sources
 * @description Extracting archives from user-controlled inputs without sanitizing file paths 
 *              can lead to writing files outside the intended directory (path traversal). 
 *              This vulnerability arises when tarballs are obtained from untrusted sources, 
 *              such as network locations or user-supplied arguments.
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

// This query identifies data flow from an untrusted input (source) to an archive extraction point (sink).
// The flow is traced to ensure that the untrusted data reaches the extraction without proper sanitization.
// The result reports the extraction location along with the flow path.
from UnsafeUnpackFlow::PathNode untrustedInput, UnsafeUnpackFlow::PathNode extractionPoint
where UnsafeUnpackFlow::flowPath(untrustedInput, extractionPoint)
select extractionPoint.getNode(), untrustedInput, extractionPoint,
  "Path traversal via unsanitized archive extraction from untrusted origin"