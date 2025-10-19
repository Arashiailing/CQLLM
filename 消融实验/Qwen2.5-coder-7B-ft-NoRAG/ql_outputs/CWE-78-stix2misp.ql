/**
 * @name Uncontrolled command line
 * @description Using externally controlled strings in a command line may allow a malicious user to change the meaning of the command.
 * @id py/stix2misp
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(), "user-provided value"