import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in a context requiring validation", source.getNode()