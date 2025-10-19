import python
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import semmle.python.security.dataflow.XpathInjectionQuery
import semmle.python.security.dataflow.PolynomialReDoSQuery
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import semmle.python.security.dataflow.InsecureDeserializationQuery
import semmle.python.security.dataflow.IncompleteHostnameRegExp
import semmle.python.security.dataflow.InsecureRegularExpressions

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into cookie construction", source.getNode()

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into command execution", source.getNode()

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into deserialization", source.getNode()

from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
where XpathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into XPath expression", source.getNode()

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input flows into shell command", source.getNode()

from IncompleteHostnameRegExp::Problem problem
select problem, "Incomplete hostname regex pattern"

from InsecureRegularExpressions::Problem problem
select problem, "Insecure regular expression pattern"