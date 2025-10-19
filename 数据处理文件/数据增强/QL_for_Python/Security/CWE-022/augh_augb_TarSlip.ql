/**
 * @name Arbitrary file write during tarfile extraction
 * @description Identifies directory traversal vulnerabilities in tar extraction processes where untrusted archive contents could overwrite files outside the intended extraction directory
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

// Trace vulnerable data flows from untrusted origins to extraction targets
from TarSlipFlow::PathNode maliciousOriginNode, TarSlipFlow::PathNode extractionTargetNode
where 
  // Confirm data flow path exists between origin and target
  TarSlipFlow::flowPath(maliciousOriginNode, extractionTargetNode)
select 
  extractionTargetNode.getNode(), 
  maliciousOriginNode, 
  extractionTargetNode, 
  "This file extraction depends on a $@.", 
  maliciousOriginNode.getNode(),
  "potentially untrusted source"