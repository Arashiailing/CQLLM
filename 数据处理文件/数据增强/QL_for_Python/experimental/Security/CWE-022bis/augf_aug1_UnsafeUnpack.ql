/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Identifies potentially dangerous tar extraction operations that lack
 *              proper path validation, enabling attackers to write files outside
 *              the intended destination directory. This vulnerability manifests
 *              when tar archives are obtained from untrusted sources such as
 *              network downloads or user-provided inputs.
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

// Detect vulnerable extraction flows originating from untrusted sources
from UnsafeUnpackFlow::PathNode taintedOrigin, UnsafeUnpackFlow::PathNode dangerousSink
where 
  // Establish data flow from untrusted source to vulnerable extraction point
  UnsafeUnpackFlow::flowPath(taintedOrigin, dangerousSink)
select dangerousSink.getNode(), taintedOrigin, dangerousSink,
  "Potentially unsafe tarball extraction from untrusted source may lead to directory traversal"