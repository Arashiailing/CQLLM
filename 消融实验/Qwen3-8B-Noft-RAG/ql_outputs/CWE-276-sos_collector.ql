/**
 * @name CWE-276: Incorrect Default Permissions
 * @id py/sos_collector
 */
import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "File operation path is influenced by untrusted data.", source.getNode(), "user-provided value"