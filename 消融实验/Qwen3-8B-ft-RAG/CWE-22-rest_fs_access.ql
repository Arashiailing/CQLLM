/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/rest_fs_access
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import semmle.python.security.dataflow.new.internal.DataFlow
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Untrusted data flows to a $@.", source.getNode(), "user-provided value"