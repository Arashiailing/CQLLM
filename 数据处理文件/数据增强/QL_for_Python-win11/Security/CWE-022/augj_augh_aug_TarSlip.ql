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

// Identify untrusted data sources and file extraction operations
from TarSlipFlow::PathNode untrustedSource, TarSlipFlow::PathNode extractionSink
// Verify data flow propagation from untrusted source to extraction point
where TarSlipFlow::flowPath(untrustedSource, extractionSink)
// Report findings: extraction operation, untrusted source, flow path, and security warning
select extractionSink.getNode(), untrustedSource, extractionSink, 
  "This file extraction depends on a $@.", untrustedSource.getNode(),
  "potentially untrusted source"