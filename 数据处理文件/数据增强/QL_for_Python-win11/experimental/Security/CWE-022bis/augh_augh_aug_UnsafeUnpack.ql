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

// Identify untrusted data sources and dangerous unpack operations
from UnsafeUnpackFlow::PathNode untrustedSource, UnsafeUnpackFlow::PathNode dangerousSink

// Verify data flow path exists between untrusted source and dangerous sink
where UnsafeUnpackFlow::flowPath(untrustedSource, dangerousSink)

// Report vulnerability with source and sink locations
select dangerousSink.getNode(), untrustedSource, dangerousSink,
  "Dangerous unpack operation: Malicious tar file from untrusted remote location may lead to directory traversal attack"