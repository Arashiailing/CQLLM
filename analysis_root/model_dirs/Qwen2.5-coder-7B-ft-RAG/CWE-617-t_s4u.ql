/**
 * @name CWE-617: Reachable Assertion
 * @description nan
 * @kind path-problem
 * @id py/t_s4u
 */

import python
import semmle.python.dataflow.new.TaintedInput
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@", source.getNode(), "user-provided value"