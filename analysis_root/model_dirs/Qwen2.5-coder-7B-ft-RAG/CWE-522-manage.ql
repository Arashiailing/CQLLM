/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description nan
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/manage
 */

import python
import semmle.python.security.dataflow.ManagePasswordQuery
import ManagePasswordFlow::PathGraph
from ManagePasswordFlow::PathNode source, ManagePasswordFlow::PathNode sink
where ManagePasswordFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Password is stored without sufficient protection."