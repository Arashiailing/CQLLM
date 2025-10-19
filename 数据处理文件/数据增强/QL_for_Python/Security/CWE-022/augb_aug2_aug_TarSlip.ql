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

// Identify untrusted data sources and vulnerable extraction targets
from TarSlipFlow::PathNode taintedSource, TarSlipFlow::PathNode vulnerableSink
// Verify data flow propagation from source to extraction point
where TarSlipFlow::flowPath(taintedSource, vulnerableSink)
// Report findings with vulnerability context
select vulnerableSink.getNode(), 
       taintedSource, 
       vulnerableSink, 
       "This file extraction depends on a $@.", 
       taintedSource.getNode(),
       "potentially uncontrolled input source"