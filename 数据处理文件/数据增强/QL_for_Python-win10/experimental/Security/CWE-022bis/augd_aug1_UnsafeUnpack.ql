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

// Define flow source and sink nodes with descriptive names
from UnsafeUnpackFlow::PathNode maliciousOrigin, UnsafeUnpackFlow::PathNode vulnerableExtraction
where 
  // Establish data flow from malicious source to unsafe extraction point
  UnsafeUnpackFlow::flowPath(maliciousOrigin, vulnerableExtraction)
select 
  vulnerableExtraction.getNode(), 
  maliciousOrigin, 
  vulnerableExtraction,
  "Unsafe extraction from malicious tarball retrieved from remote location"