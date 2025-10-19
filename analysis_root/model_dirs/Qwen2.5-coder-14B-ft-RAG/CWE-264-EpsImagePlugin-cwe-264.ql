/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @description nan
 * @kind path-problem
 * @id py/EpsImagePlugin-cwe-264
 * @problem.severity error
 * @precision high
 * @security-severity 7.5
 * @tags security
 *       external/cwe/cwe-264
 */

import python
import semmle.python.security.dataflow.EpsImagePluginQuery
import EpsImagePluginFlow::PathGraph

from EpsImagePluginFlow::PathNode source, EpsImagePluginFlow::PathNode sink
where EpsImagePluginFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"