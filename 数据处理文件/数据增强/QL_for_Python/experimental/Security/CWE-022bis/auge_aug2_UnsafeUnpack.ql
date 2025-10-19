/**
 * @name Arbitrary file write during tarball extraction from untrusted source
 * @description Extracting tarballs from uncontrolled sources without validating
 *              destination paths may allow unauthorized file writes outside the
 *              target directory. This occurs when tarballs originate from
 *              user-controlled inputs, such as remote sources or CLI arguments.
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

// Identify flow sources and sinks for unsafe unpacking operations
from UnsafeUnpackFlow::PathNode taintedSource, UnsafeUnpackFlow::PathNode extractionSink
where UnsafeUnpackFlow::flowPath(taintedSource, extractionSink)
// Report vulnerable extraction point with full flow context
select extractionSink.getNode(), taintedSource, extractionSink,
  "Dangerous tarball extraction from untrusted external source"