/**
 * @name Directory traversal during tarball extraction from attacker-controlled source
 * @description Identifies insecure tar extraction operations lacking path validation against destination directory,
 *              enabling arbitrary file writes outside target location. Exploitable when tar files
 *              originate from attacker-controlled inputs (remote sources or CLI arguments).
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

// Identify data flow paths from attacker-controlled sources to vulnerable extraction points
from UnsafeUnpackFlow::PathNode attackerControlledSource, UnsafeUnpackFlow::PathNode vulnerableExtractionPoint
where UnsafeUnpackFlow::flowPath(attackerControlledSource, vulnerableExtractionPoint)
select vulnerableExtractionPoint.getNode(), attackerControlledSource, vulnerableExtractionPoint,
  "Unsafe extraction from malicious tarball retrieved from remote location"