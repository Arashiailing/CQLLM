/**
 * @name Arbitrary file write during tarfile extraction
 * @description Extracting tar archives without validating destination paths
 *              may lead to directory traversal attacks, enabling arbitrary
 *              file overwrites outside the target directory.
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph

// Identify vulnerable extraction points and their malicious input sources
from TarSlipFlow::PathNode maliciousInput, TarSlipFlow::PathNode vulnerableExtraction
// Verify data flow propagation from untrusted source to extraction sink
where TarSlipFlow::flowPath(maliciousInput, vulnerableExtraction)
// Report findings with security context
select vulnerableExtraction.getNode(), maliciousInput, vulnerableExtraction, 
  "This file extraction depends on a $@.", maliciousInput.getNode(),
  "potentially untrusted source"