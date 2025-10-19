/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies unsafe tar extraction operations lacking proper path validation 
 *              against target directories, enabling potential overwrites outside the 
 *              intended extraction scope. This vulnerability occurs when tar archives 
 *              originate from user-influenced sources (network resources or CLI arguments).
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

// Define source and sink nodes for the vulnerability path
from UnsafeUnpackFlow::PathNode attackerControlledSource, 
     UnsafeUnpackFlow::PathNode vulnerableExtractionPoint
// Trace data flow from attacker-controlled origin to unsafe extraction
where UnsafeUnpackFlow::flowPath(attackerControlledSource, vulnerableExtractionPoint)
// Report vulnerable extraction location with full flow context
select vulnerableExtractionPoint.getNode(), 
       attackerControlledSource, 
       vulnerableExtractionPoint,
       "Dangerous extraction of tarball from attacker-controlled source without path validation"