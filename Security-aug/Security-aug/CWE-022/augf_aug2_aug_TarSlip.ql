/**
 * @name Arbitrary file write during tarfile extraction
 * @description Detects directory traversal vulnerabilities in tar extraction
 *              where untrusted input can overwrite files outside the target
 *              directory through path manipulation.
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

// Define source and sink variables for path traversal detection
from TarSlipFlow::PathNode untrustedSource, TarSlipFlow::PathNode vulnerableExtraction

// Verify data flow propagation from untrusted input to extraction point
where TarSlipFlow::flowPath(untrustedSource, vulnerableExtraction)

// Report vulnerability with security context and flow details
select vulnerableExtraction.getNode(), untrustedSource, vulnerableExtraction, 
  "This file extraction depends on a $@.", untrustedSource.getNode(),
  "potentially uncontrolled input source"