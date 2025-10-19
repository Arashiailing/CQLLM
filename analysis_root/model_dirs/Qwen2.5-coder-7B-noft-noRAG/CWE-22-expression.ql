import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink, ExternalApiUsedWithUntrustedData untrustedApi
where
  sink.getNode() = untrustedApi.getUntrustedDataNode() and
  PathInjectionFlow::flowPath(source, sink)
select untrustedApi.getSink(), source, sink, "Call to " + untrustedApi.toString() + " with untrusted data from $@.", source.getNode(), source.toString()