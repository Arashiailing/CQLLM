/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description Detects unsafe tarball extraction where destination paths aren't validated against target directory boundaries.
 *             This occurs when tar archives originate from user-controlled sources (remote locations or CLI arguments),
 *             potentially allowing files to be written outside the intended extraction directory.
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

from UnsafeUnpackFlow::PathNode maliciousSource, 
     UnsafeUnpackFlow::PathNode unsafeExtractionTarget
where UnsafeUnpackFlow::flowPath(maliciousSource, unsafeExtractionTarget)
select unsafeExtractionTarget.getNode(), 
       maliciousSource, 
       unsafeExtractionTarget,
       "Unsafe extraction from a malicious tarball retrieved from a remote location."