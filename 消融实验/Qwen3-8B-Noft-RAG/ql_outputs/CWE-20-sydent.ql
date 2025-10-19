import python
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import semmle.python.security.dataflow.ReflectedXssQuery
import semmle.python.security.dataflow.SqlInjectionQuery
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Command injection due to unvalidated input", source.getNode()

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cookie injection due to unvalidated input", source.getNode()

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Header injection due to unvalidated input", source.getNode()

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XSS due to unvalidated input", source.getNode()

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "SQL injection due to unvalidated input", source.getNode()

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization due to unvalidated input", source.getNode()