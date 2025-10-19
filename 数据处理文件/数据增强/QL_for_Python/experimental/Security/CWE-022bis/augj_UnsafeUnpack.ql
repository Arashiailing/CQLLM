/**
 * @name Arbitrary file write during tarball extraction from user-controlled source
 * @description Extracting tar files from user-controlled sources without validating 
 *              destination paths may allow overwriting files outside the target directory.
 *              This occurs when tarballs originate from user-controlled locations,
 *              whether remote or via command-line arguments.
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

// Define path nodes for vulnerability tracking
from UnsafeUnpackFlow::PathNode maliciousSource, UnsafeUnpackFlow::PathNode extractionSink
where UnsafeUnpackFlow::flowPath(maliciousSource, extractionSink)
// Report vulnerability with path context
select extractionSink.getNode(), 
       maliciousSource, 
       extractionSink,
       "Unsafe extraction of malicious tarball from uncontrolled remote source"