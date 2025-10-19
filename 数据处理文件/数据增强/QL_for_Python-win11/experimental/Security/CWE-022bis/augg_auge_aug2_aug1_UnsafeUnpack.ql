/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies hazardous tar extraction operations lacking destination path validation 
 *              against target directories, enabling potential file overwrites beyond intended 
 *              extraction scope. This vulnerability manifests when tar archives originate from 
 *              user-influenced sources (network resources or CLI arguments).
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

// Identify attacker-controlled sources and vulnerable extraction points
from 
  UnsafeUnpackFlow::PathNode attackerControlledSource,
  UnsafeUnpackFlow::PathNode vulnerableExtractionPoint
// Trace data flow paths from malicious origin to unsafe extraction
where 
  UnsafeUnpackFlow::flowPath(attackerControlledSource, vulnerableExtractionPoint)
// Report extraction vulnerability with attack flow context
select 
  vulnerableExtractionPoint.getNode(), 
  attackerControlledSource, 
  vulnerableExtractionPoint,
  "Hazardous extraction of attacker-controlled tarball from external source"