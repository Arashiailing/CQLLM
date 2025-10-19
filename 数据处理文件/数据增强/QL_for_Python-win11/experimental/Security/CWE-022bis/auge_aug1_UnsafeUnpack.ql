/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies unsafe tar extraction operations where destination paths aren't 
 *              properly sanitized against the target directory. This vulnerability allows 
 *              attackers to overwrite files outside the intended extraction location when 
 *              processing tarballs from untrusted sources (network inputs or user arguments).
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

// Trace data flow from uncontrolled tarball sources to vulnerable extraction sinks
from UnsafeUnpackFlow::PathNode uncontrolledSource, UnsafeUnpackFlow::PathNode vulnerableSink
where UnsafeUnpackFlow::flowPath(uncontrolledSource, vulnerableSink)
select vulnerableSink.getNode(), uncontrolledSource, vulnerableSink,
  "Path traversal vulnerability in tar extraction from untrusted source"