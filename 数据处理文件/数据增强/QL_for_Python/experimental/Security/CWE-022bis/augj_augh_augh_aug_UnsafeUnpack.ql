/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies directory traversal vulnerabilities when extracting tar files without 
 *              validating target paths against the intended directory. This occurs when tar files 
 *              originate from untrusted sources like remote servers or user-controlled inputs.
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
 * This query detects unsafe tar extraction operations where the tarball source
 * is user-controlled, potentially enabling directory traversal attacks. The analysis
 * traces data flow from untrusted sources to vulnerable unpack operations.
 */

// Identify untrusted input sources and vulnerable extraction targets
from UnsafeUnpackFlow::PathNode maliciousInput, UnsafeUnpackFlow::PathNode extractionTarget

// Verify data flow path exists between untrusted source and vulnerable sink
where UnsafeUnpackFlow::flowPath(maliciousInput, extractionTarget)

// Report vulnerability with source and sink locations
select extractionTarget.getNode(), maliciousInput, extractionTarget,
  "Dangerous unpack operation: Malicious tar file from untrusted remote location may lead to directory traversal attack"