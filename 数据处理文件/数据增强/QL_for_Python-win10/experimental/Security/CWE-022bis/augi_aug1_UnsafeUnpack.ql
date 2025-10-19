/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies unsafe tar extraction operations where destination paths 
 *              lack validation against the target directory, enabling potential 
 *              overwrites outside the intended location. This vulnerability occurs 
 *              when tar archives originate from untrusted sources such as remote 
 *              endpoints or user-supplied command-line arguments.
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

// Trace vulnerable extraction paths from uncontrolled sources to unsafe extraction points
from UnsafeUnpackFlow::PathNode untrustedOrigin, UnsafeUnpackFlow::PathNode vulnerableExtraction
where 
  // Establish data flow from malicious source to unsafe extraction sink
  UnsafeUnpackFlow::flowPath(untrustedOrigin, vulnerableExtraction)
select 
  vulnerableExtraction.getNode(), 
  untrustedOrigin, 
  vulnerableExtraction,
  "Unsafe extraction from malicious tarball retrieved from remote location"