import python
import semmle.python.security.dataflow.RegexInjectionQuery
import RegexInjectionFlow::PathGraph

from RegexInjectionFlow::PathNode source, RegexInjectionFlow::PathNode sink
where RegexInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Regular expression is constructed from a $@.", source.getNode(), "user-provided value"