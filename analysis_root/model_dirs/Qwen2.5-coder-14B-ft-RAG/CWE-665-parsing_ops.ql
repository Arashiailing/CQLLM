/**
 * @name CWE-665: Improper Initialization
 * @description nan
 * @kind problem
 * @id py/parsing_ops
 * @problem.severity recommendation
 * @tags reliability
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

from DataFlow::Node f, DataFlow::Node t, API::Node p, string s
where
  (
    s = "re" and
    p = API::moduleImport(s)
  )
  or
  (
    s = "json" and
    p = API::moduleImport(s)
  )
  or
  (
    s = "pickle" and
    p = API::moduleImport(s)
  )
  or
  (
    s = "cPickle" and
    p = API::moduleImport(s)
  )
  or
  (
    s = "marshal" and
    p = API::moduleImport(s)
  )
  or
  (
    s = "yaml" and
    p = API::moduleImport(s)
  )
  and
  (
    f = p.getMember("loads")
     .getACall()
     .getNode()
     .getAValueReachableFromSource*()
     .asExpr()
     .(DataFlow::Return)
     .getNode()
     .getAFlowNode*()
     .asExpr()
     .(Call)
     .getArg(0)
     .asExpr()
     .(DataFlow::Node)
     .getASink*()
     .asExpr()
     .(DataFlow::Node)
     .getAFlowNode*()
     .asExpr()
     .(DataFlow::Node)
     .getATarget*()
     .asExpr()
     .(DataFlow::Node)
     .getAFlowNode*()
     .asExpr()
     .(DataFlow::Node)
     .getASource*()
     .asExpr()
     .(DataFlow::Node)
  )
  and
  f.asExpr().(Call).getArg(0).asExpr().(DataFlow::Node).getASink*() = t
select f, t, "Loading potentially untrusted data with $@ could create a security vulnerability.", p,
  p.toString()