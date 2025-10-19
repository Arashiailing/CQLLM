import python
import semmle.python.security.dataflow::SQLInjection

from UserInputSource source, SQLInjection::SQLInjectionSink sink
where source.asExpr().isIn(SQLInjection::getSQLInjectionSources()) and
      sink.asExpr().isIn(SQLInjection::getSQLInjectionSinks()) and
      source.asExpr().getEnclosingCallable() = sink.asExpr().getEnclosingCallable()
select source, "This user input is used to build an SQL query, which may be vulnerable to SQL injection."