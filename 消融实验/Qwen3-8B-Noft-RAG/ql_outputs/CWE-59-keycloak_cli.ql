/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @id py/keycloak_cli
 */
import python
import semmle.python.security.dataflow.ZipSlipQuery
import ZipSlipFlow::PathGraph

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential TarSlip vulnerability detected: path manipulation leads to arbitrary file overwrite.", source.getNode(), "user-controlled path"