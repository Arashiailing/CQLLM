import python
import semmle.python.security.dataflow.SqlInjectionQuery
import SqlInjectionFlow::PathGraph

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This SQL query depends on a $@.", source.getNode(), "user-provided value"