import python
import experimental.semmle.python.security.dataflow.SqlInjection
import SqlInjectionFlow::PathGraph

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "SQL query built from $@.", source.getNode(), "user-controlled sources"