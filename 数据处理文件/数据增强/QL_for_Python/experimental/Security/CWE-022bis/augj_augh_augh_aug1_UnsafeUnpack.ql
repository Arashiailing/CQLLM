/**
 * @name Directory traversal during tarball extraction from attacker-controlled source
 * @description Detects insecure tar extraction operations lacking path validation against destination directory,
 *              enabling attackers to write files outside intended locations. Exploitable when tar files
 *              originate from untrusted inputs (remote sources or user-provided arguments).
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
from UnsafeUnpackFlow::PathNode maliciousInputSource, UnsafeUnpackFlow::PathNode unsafeExtractionTarget
where UnsafeUnpackFlow::flowPath(maliciousInputSource, unsafeExtractionTarget)
select unsafeExtractionTarget.getNode(), maliciousInputSource, unsafeExtractionTarget,
  "Unsafe extraction from malicious tarball retrieved from remote location"