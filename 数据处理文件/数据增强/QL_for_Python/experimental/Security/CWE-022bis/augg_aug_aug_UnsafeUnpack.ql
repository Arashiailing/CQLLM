/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Detects directory traversal vulnerabilities when extracting user-controlled tar files.
 *             Occurs when target paths aren't validated against the destination directory.
 *             Vulnerable when tar files originate from untrusted sources (remote servers/user input).
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

// Identify taint flow from user-controlled sources to unsafe unpacking operations
from UnsafeUnpackFlow::PathNode taintedSource, UnsafeUnpackFlow::PathNode vulnerableSink
where UnsafeUnpackFlow::flowPath(taintedSource, vulnerableSink)
// Report vulnerability details with security context
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "Directory traversal: Malicious tar from untrusted source may overwrite arbitrary files during extraction"