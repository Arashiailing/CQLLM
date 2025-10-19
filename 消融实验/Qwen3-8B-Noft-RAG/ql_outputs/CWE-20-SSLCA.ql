import python
import ExternalAPIs
import UntrustedDataToExternalApiFlow::PathGraph

from UntrustedDataToExternalApiFlow::PathNode source, UntrustedDataToExternalApiFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where sink.getNode() = externalApi.getUntrustedDataNode() and UntrustedDataToExternalApiFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Untrusted data flows to external API call", externalApi.getQualifiedName()