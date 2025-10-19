/**
 * @name Arbitrary file write during tarfile extraction
 * @description Identifies directory traversal vulnerabilities in tar extraction where
 *              untrusted archive contents could overwrite files outside the target directory.
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

// Detect vulnerable extraction flows from untrusted sources to extraction sinks
from TarSlipFlow::PathNode untrustedSrc, TarSlipFlow::PathNode vulnerableSink
where 
  // Ensure data flow path exists between untrusted source and extraction sink
  TarSlipFlow::flowPath(untrustedSrc, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  untrustedSrc, 
  vulnerableSink, 
  "This file extraction depends on a $@.", 
  untrustedSrc.getNode(),
  "potentially untrusted source"