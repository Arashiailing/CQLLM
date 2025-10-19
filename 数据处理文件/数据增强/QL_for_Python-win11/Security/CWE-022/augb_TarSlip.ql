/**
 * @name Arbitrary file write during tarfile extraction
 * @description Detects potential directory traversal vulnerabilities during tar extraction where untrusted archive contents could overwrite files outside the target directory.
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

// Identify vulnerable extraction flows from untrusted sources to extraction sinks
from TarSlipFlow::PathNode untrustedSourceNode, TarSlipFlow::PathNode extractionSinkNode
where 
  // Verify data flow path exists between source and sink
  TarSlipFlow::flowPath(untrustedSourceNode, extractionSinkNode)
select 
  extractionSinkNode.getNode(), 
  untrustedSourceNode, 
  extractionSinkNode, 
  "This file extraction depends on a $@.", 
  untrustedSourceNode.getNode(),
  "potentially untrusted source"