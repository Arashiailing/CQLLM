/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Detects unsafe tar extraction operations where destination paths are not validated 
 *              against target directories. This allows attackers to overwrite files outside the 
 *              intended extraction scope when tar archives originate from user-controlled sources 
 *              like network inputs or CLI arguments.
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

// Define data flow components for vulnerability tracking
from 
  UnsafeUnpackFlow::PathNode maliciousOrigin,  // Attacker-controlled input source
  UnsafeUnpackFlow::PathNode extractionTarget  // Vulnerable extraction operation
// Establish data flow relationship between components
where 
  UnsafeUnpackFlow::flowPath(maliciousOrigin, extractionTarget)
// Report vulnerability with attack vector details
select 
  extractionTarget.getNode(),  // Vulnerable extraction point
  maliciousOrigin,            // Attack source
  extractionTarget,           // Path endpoint
  "Unsafe extraction of attacker-controlled tarball allowing directory traversal"