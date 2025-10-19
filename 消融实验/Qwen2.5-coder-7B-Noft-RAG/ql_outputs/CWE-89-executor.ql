/**
* @name CWE-89: SQL query built
from user-controlled sources
*
@description Building a SQL query
from user-controlled sources is vulnerable to insertion of malicious SQL code by the user.
*
@id py/executor
*/
import python
import semmle.python.security.dataflow.SqlInjectionQuery
import SqlInjectionFlow::PathGraph
from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
    where SqlInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This SQL query depends on a $@.", source.getNode(), "user-provided value"