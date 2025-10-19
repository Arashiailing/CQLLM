/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Detects unsafe tar extraction operations where destination paths lack proper 
 *             validation against the target directory, enabling potential overwrites outside 
 *             the intended extraction scope. This vulnerability occurs when tar archives 
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

// Define nodes representing malicious source and unsafe extraction point
from UnsafeUnpackFlow::PathNode maliciousSourceNode, UnsafeUnpackFlow::PathNode unsafeExtractionNode
// Identify data flow paths from attacker-controlled origin to vulnerable extraction
where UnsafeUnpackFlow::flowPath(maliciousSourceNode, unsafeExtractionNode)
// Report vulnerable extraction location with flow context
select unsafeExtractionNode.getNode(), maliciousSourceNode, unsafeExtractionNode,
  "Dangerous extraction of attacker-controlled tarball from remote source"