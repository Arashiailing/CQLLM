/**
 * @name CWE-255: Unsafe Shell Command Construction Query
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/unsafe-shell-command-construction-query
 * @tags security
 */

import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import UnsafeShellCommandConstructionFlow::PathGraph

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe shell command constructed from user input."