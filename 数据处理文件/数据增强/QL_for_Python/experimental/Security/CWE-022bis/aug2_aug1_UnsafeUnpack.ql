/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies unsafe tar extraction operations where destination paths lack proper 
 *             validation against the target directory, enabling potential overwrites outside 
 *             the intended extraction scope. This vulnerability manifests when tar archives 
 *             originate from user-influenced sources (network resources or CLI arguments).
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

// Trace vulnerable extraction paths from attacker-controlled origins to unsafe extraction points
from UnsafeUnpackFlow::PathNode attackerOrigin, UnsafeUnpackFlow::PathNode vulnerableExtraction
where UnsafeUnpackFlow::flowPath(attackerOrigin, vulnerableExtraction)
select vulnerableExtraction.getNode(), attackerOrigin, vulnerableExtraction,
  "Dangerous extraction of attacker-controlled tarball from remote source"