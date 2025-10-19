import python
import semmle.python.security.dataflow.PathInjectionQuery
import semmle.python.security.dataflow.UntrustedDataToExternalApiFlow

from PathInjectionFlow::PathNode source, UntrustedDataToExternalApiFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where UntrustedDataToExternalApiFlow::flowPath(source, sink) and
      sink.getNode() = externalApi.getUntrustedDataNode() and
      externalApi.toString() = "bind" and
      source.getNode().getValue().toString() = "ldap"
select sink.getNode(), source, sink, "Improper authentication due to untrusted data in LDAP bind", source.getNode(), "user-provided value"