/**
 * @name Arbitrary file write during tarfile extraction
 * @description Identifies directory traversal vulnerabilities in tar extraction where untrusted archive contents could overwrite files outside the target directory
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

// Trace vulnerable extraction paths from untrusted origins to extraction targets
from TarSlipFlow::PathNode untrustedOriginNode, TarSlipFlow::PathNode extractionTargetNode
where 
  // Validate data flow connection exists between origin and target
  TarSlipFlow::flowPath(untrustedOriginNode, extractionTargetNode)
select 
  extractionTargetNode.getNode(), 
  untrustedOriginNode, 
  extractionTargetNode, 
  "This extraction operation relies on a $@.", 
  untrustedOriginNode.getNode(),
  "potentially untrusted origin"