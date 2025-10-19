import python
import semmle.python.security.dataflow::SQLInjection

from SQLInjection::SQLInjectionSource source, SQLInjection::SQLInjectionSink sink
where source.asExpr().getEnclosingCallable() = sink.getEnclosingCallable()
select source, "This query is vulnerable to SQL injection because it builds a SQL query from user-controlled sources."