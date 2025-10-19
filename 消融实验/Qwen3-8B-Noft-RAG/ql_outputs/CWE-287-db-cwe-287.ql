import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(SqlInjectionFlow::PathNode sqlBind) {
  // Check if password is not set or there's a data flow to the password field
  exists(SqlInjectionFlow::PathNode source |
    SqlInjectionFlow::flowPath(source, sqlBind) and
    source.getNode().(SqlInjectionSource).isUnsanitized()
  ) or
  sqlBind.getNode().(SqlInjectionSink).isPasswordField()
}

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink) and
      authenticatesImproperly(sink)
select sink.getNode(), source, sink, "Improper authentication due to SQL injection", source.getNode(), "user-provided value"