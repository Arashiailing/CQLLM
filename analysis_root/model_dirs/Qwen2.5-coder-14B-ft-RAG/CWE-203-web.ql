/**
 * @name CWE-203: Observable Discrepancy
 * @description nan
 * @kind path-problem
 * @id py/web
 * @precision medium
 * @problem.severity error
 * @tags external/cwe/cwe-203
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

from DataFlow::Config a, DataFlow::Node b, DataFlow::Node c, DataFlow::Node d, DataFlow::Node e
where
  exists(string f |
    (f = "debug" and
      d = a.moduleImport("flask").getMember(f).getACall()) or
    (f = "info" and
      d = a.moduleImport("logging").getMember(f).getACall())
  ) and
  not d.getLocation().getFile() instanceof Test and
  b = d.getArg(0) and
  e = a.moduleImport("request").getMember("url").getAValueReachableFromSource*() and
  (
    e.toString().matches("%client_address%") and
    e.getScope().getEndLine() < 10 and
    exists(DataFlow::Node g | g = a.moduleImport("werkzeug").getMember("request").getAValueReachableFromSource*() | c = g)
    or
    c = e
  ) and
  e.flowto(b, _)
select d.asExpr(), "This expression prints a URL which originates from an HTTP request (" + e.toString() + ")."