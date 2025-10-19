/**
 * @name CWE-276: Incorrect Default Permissions
 * @description nan
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/sos_collector
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.TarSlipQuery

from DataFlow::CallCfgNode sinkNode, DataFlow::Node filename, string fileName
where
  TarSlipFlow::flowPath(TarSlipFlow::anySource(), sinkNode)
  and
  filename = sinkNode.(Sink).getNode()
  and
  fileName = filename.toString()
select sinkNode.asExpr(),
  "Potential path traversal vulnerability: the filename '" + fileName +
  "' is constructed from a $@.", filename,
  "user-controlled value"