import python
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import semmle.python.security.dataflow.XpathInjectionQuery
import semmle.python.security.dataflow.PolynomialReDoSQuery
import ExternalAPIs
import UntrustedDataToExternalApiFlow::PathGraph
import CookieInjectionFlow::PathGraph
import CommandInjectionFlow::PathGraph
import UnsafeShellCommandConstructionFlow::PathGraph
import UnsafeDeserializationFlow::PathGraph
import XpathInjectionFlow::PathGraph
import PolynomialReDoSFlow::PathGraph

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cookie is constructed from unvalidated input", source.getNode()

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Command injection vulnerability", source.getNode()

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe shell command construction", source.getNode()

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization of untrusted data", source.getNode()

from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
where XpathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XPath injection vulnerability", source.getNode()

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential ReDoS vulnerability", source.getNode()

from ExternalApiUsedWithUntrustedData externalApi
select externalApi, "Untrusted data passed to external API", externalApi.getUntrustedDataNode()