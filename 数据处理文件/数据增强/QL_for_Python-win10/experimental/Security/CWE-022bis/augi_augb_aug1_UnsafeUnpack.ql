/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies insecure tar extraction operations lacking proper destination path sanitization,
 *              potentially enabling writes outside the intended directory. This vulnerability occurs when
 *              tar archives are sourced from untrusted locations such as network endpoints or user inputs.
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

// Identify data flows from untrusted tar sources to vulnerable extraction points
from UnsafeUnpackFlow::PathNode untrustedSource, UnsafeUnpackFlow::PathNode extractionPoint
where UnsafeUnpackFlow::flowPath(untrustedSource, extractionPoint)
select extractionPoint.getNode(), untrustedSource, extractionPoint,
  "Insecure extraction of tarball from untrusted source may lead to path traversal"