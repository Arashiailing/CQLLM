/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Detects unsafe tar extraction where target paths aren't validated against 
 *             the destination directory, potentially allowing overwrites outside the target.
 *             This occurs when tar files originate from user-controlled sources (remote 
 *             locations or command-line arguments).
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

// Identify vulnerable extraction flows from malicious sources to unsafe sinks
from UnsafeUnpackFlow::PathNode maliciousSource, UnsafeUnpackFlow::PathNode unsafeSink
where UnsafeUnpackFlow::flowPath(maliciousSource, unsafeSink)
select unsafeSink.getNode(), maliciousSource, unsafeSink,
  "Unsafe extraction from malicious tarball retrieved from remote location"