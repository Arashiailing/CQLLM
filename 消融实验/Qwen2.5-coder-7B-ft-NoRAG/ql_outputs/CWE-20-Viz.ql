/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 * not validate or incorrectly validates that the input has the
 * properties that are required to process the data safely and
 * correctly.
 * @id py/Viz
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),  "user-provided value"