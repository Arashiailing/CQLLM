/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Extracting tar files from user-controlled sources without validating 
 *              destination paths may allow overwriting files outside the target directory.
 *              This occurs when tarballs originate from user-controlled locations,
 *              whether remote sources or command-line arguments.
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

// Define origin and destination points for unsafe unpacking flows
from UnsafeUnpackFlow::PathNode maliciousOrigin, UnsafeUnpackFlow::PathNode vulnerableTarget
// Ensure data flows from malicious origin to vulnerable target
where UnsafeUnpackFlow::flowPath(maliciousOrigin, vulnerableTarget)
// Report the vulnerable target location with flow context
select vulnerableTarget.getNode(), maliciousOrigin, vulnerableTarget,
  "Unsafe extraction of malicious tarball from untrusted remote source"