/**
 * @name Arbitrary file write during tarfile extraction
 * @description Extracting tar archives without validating destination paths
 *              can lead to directory traversal attacks, allowing arbitrary
 *              file writes outside the target directory.
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

// Identify untrusted input sources and vulnerable extraction sinks
from TarSlipFlow::PathNode maliciousInput, TarSlipFlow::PathNode extractionSink
// Verify data flow propagation from input to extraction point
where TarSlipFlow::flowPath(maliciousInput, extractionSink)
// Report findings with vulnerability context
select extractionSink.getNode(), maliciousInput, extractionSink, 
  "This file extraction depends on a $@.", maliciousInput.getNode(),
  "potentially uncontrolled input source"