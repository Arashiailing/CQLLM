import python
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import semmle.python.security.dataflow.XpathInjectionQuery
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import semmle.python.security.dataflow.IncompleteHostnameRegExp
import semmle.python.security.dataflow.PolynomialReDoSQuery

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in a context requiring validation", source.getNode()

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in a command execution context", source.getNode()

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in shell command construction", source.getNode()

from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
where XpathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in XPath query", source.getNode()

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in deserialization", source.getNode()

from HostnameRegex::PathNode source, HostnameRegex::PathNode sink
where HostnameRegex::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in hostname regex matching", source.getNode()

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input is used in potentially vulnerable regex", source.getNode()