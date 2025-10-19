/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Detects potential directory traversal attacks when extracting tar files without validating 
 *              if the target path is within the intended directory. This vulnerability occurs when 
 *              tar files originate from untrusted locations such as remote servers or user input parameters.
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

/**
 * This query identifies unsafe tar extraction operations where the source
 * of the tar file is user-controlled, potentially leading to directory traversal attacks.
 * The analysis tracks data flow from untrusted sources to dangerous unpack operations.
 */

// Define source and sink nodes for the vulnerability path
from UnsafeUnpackFlow::PathNode sourceNode, UnsafeUnpackFlow::PathNode sinkNode

// Check if there exists a data flow path from user-controlled source to dangerous unpack operation
where UnsafeUnpackFlow::flowPath(sourceNode, sinkNode)

// Output the vulnerability location with source and sink nodes, along with security alert
select sinkNode.getNode(), sourceNode, sinkNode,
  "Dangerous unpack operation: Malicious tar file from untrusted remote location may lead to directory traversal attack"