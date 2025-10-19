/**
 * @name Arbitrary file write during tarfile extraction
 * @description Identifies potential directory traversal vulnerabilities during tar extraction where untrusted archive contents could overwrite files outside the target directory.
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
from 
  TarSlipFlow::PathNode untrustedOriginNode, 
  TarSlipFlow::PathNode extractionTargetNode
where 
  // Verify data flow path exists between source and sink
  TarSlipFlow::flowPath(untrustedOriginNode, extractionTargetNode)
select 
  extractionTargetNode.getNode(), 
  untrustedOriginNode, 
  extractionTargetNode, 
  "This file extraction depends on a $@.", 
  untrustedOriginNode.getNode(),
  "potentially untrusted source"