/**
* @name CWE-400: Uncontrolled Resource Consumption
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
* @kind path-problem
* @problem.severity error
* @precision high
* @security-severity 9.3
*
@id py/push_rule_evaluator
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"