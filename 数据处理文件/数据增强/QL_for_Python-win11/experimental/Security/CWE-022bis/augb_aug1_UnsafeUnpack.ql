/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies insecure tar extraction operations where destination paths 
 *             are not properly sanitized, potentially enabling writes outside the 
 *             intended directory. This vulnerability arises when tar archives are 
 *             obtained from untrusted sources such as network endpoints or user inputs.
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

// Detect data flows from untrusted tar sources to vulnerable extraction points
from UnsafeUnpackFlow::PathNode untrustedOrigin, UnsafeUnpackFlow::PathNode vulnerableExtraction
where UnsafeUnpackFlow::flowPath(untrustedOrigin, vulnerableExtraction)
select vulnerableExtraction.getNode(), untrustedOrigin, vulnerableExtraction,
  "Insecure extraction of tarball from untrusted source may lead to path traversal"