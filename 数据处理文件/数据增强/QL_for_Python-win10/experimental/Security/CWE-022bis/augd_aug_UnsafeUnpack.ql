/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Detects potential directory traversal attacks when extracting tar files from untrusted sources.
 *             Occurs when target paths aren't validated against the destination directory during extraction.
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

// Identify vulnerable extraction operations with data flow from untrusted sources
from UnsafeUnpackFlow::PathNode sourceNode, UnsafeUnpackFlow::PathNode sinkNode
// Verify data flow path exists between user-controlled source and dangerous extraction
where UnsafeUnpackFlow::flowPath(sourceNode, sinkNode)
// Report vulnerability location with flow context and security warning
select sinkNode.getNode(), sourceNode, sinkNode,
  "Unsafe tar extraction: Malicious tarball from untrusted remote source may lead to directory traversal"