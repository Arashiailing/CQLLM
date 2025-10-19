import python
import semmle.python.dataflow.new.DataFlow
import CommandInjectionQuery::PathGraph

from CommandInjectionQuery::PathNode source, CommandInjectionQuery::PathNode sink
where CommandInjectionQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(), "user-provided value"