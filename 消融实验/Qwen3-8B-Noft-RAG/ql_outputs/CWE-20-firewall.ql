import python
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into cookie construction", source.getNode()

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into command injection", source.getNode()

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into HTTP header construction", source.getNode()

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into unsafe shell command", source.getNode()