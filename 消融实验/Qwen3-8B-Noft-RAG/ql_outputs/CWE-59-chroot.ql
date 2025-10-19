/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @id py/chroot
 */
import python
import semmle.python.security.dataflow.PathInjectionQuery
import UntrustedDataToExternalApiFlow::PathGraph

from UntrustedDataToExternalApiFlow::PathNode source, UntrustedDataToExternalApiFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where 
  sink.getNode() = externalApi.getUntrustedDataNode() and
  UntrustedDataToExternalApiFlow::flowPath(source, sink)
select 
  sink.getNode(), 
  source, 
  sink, 
  "Call to " + externalApi.toString() + " with untrusted data from $@.", 
  source.getNode(), 
  source.toString()