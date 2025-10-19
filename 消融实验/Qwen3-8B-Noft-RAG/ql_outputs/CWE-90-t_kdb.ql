import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode source, LdapInjectionFlow::PathNode sink, string parameterName
where (LdapInjectionDnFlow::flowPath(source.asPathNode1(), sink.asPathNode1()) and parameterName = "DN") or (LdapInjectionFilterFlow::flowPath(source.asPathNode2(), sink.asPathNode2()) and parameterName = "filter")
select sink.getNode(), source, sink, "LDAP query parameter (" + parameterName + ") depends on a $@.", source.getNode(), "user-provided value"