import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Improper neutralization of argument delimiters in a comm
    and ('Argument Injection').", source.getNode(), "user-provided value"