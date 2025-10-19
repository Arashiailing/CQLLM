import python
import semmle.python.security.dataflow.InputValidationQuery
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected", source.getNode(), "user-provided value"

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected", source.getNode(), "user-provided value"

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected", source.getNode(), "user-provided value"

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected", source.getNode(), "user-provided value"