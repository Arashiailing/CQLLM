import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.XpathInjectionQuery
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import semmle.python.security.dataflow.IncompleteHostnameRegExp
import semmle.python.security.dataflow.IncompleteUrlSubstringSanitization
import semmle.python.security.dataflow.PolynomialReDoSQuery
import semmle.python.security.dataflow.UntrustedDataToExternalApiFlow

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(), "unvalidated input"

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Command line depends on a $@.", source.getNode(), "unvalidated input"

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cookie is constructed from a $@.", source.getNode(), "unvalidated input"

from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
where XpathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XPath expression depends on a $@.", source.getNode(), "unvalidated input"

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Shell command depends on a $@.", source.getNode(), "unvalidated input"

from IncompleteHostnameRegExp::Problem problem
select problem, "Incomplete regular expression for hostnames"

from IncompleteUrlSubstringSanitization::Problem problem
select problem, "Incomplete URL substring sanitization"

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink, PolynomialBackTrackingTerm regexp
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, regexp.toString(), "Polynomial regular expression used on untrusted data"

from UntrustedDataToExternalApiFlow::PathNode source, UntrustedDataToExternalApiFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where UntrustedDataToExternalApiFlow::flowPath(source, sink)
select externalApi, source, sink, "Untrusted data passed to external API", source.getNode(), "unvalidated input"