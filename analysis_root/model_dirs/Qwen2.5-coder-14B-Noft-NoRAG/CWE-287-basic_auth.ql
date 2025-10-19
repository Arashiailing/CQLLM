import python

/**
 * Detects instances where credentials are stored in cleartext.
 */
from DataFlow::Node source, DataFlow::Node sink
where source instanceof CallExpr and
      source.getCallee().getName() = "getpass" and
      sink instanceof CallExpr and
      sink.getCallee().getName() = "open" and
      exists(DataFlow::Path path | path.hasSource(source) and path.hasSink(sink))
select source, "CWE-287: Improper Authentication - Cleartext storage of credentials detected."