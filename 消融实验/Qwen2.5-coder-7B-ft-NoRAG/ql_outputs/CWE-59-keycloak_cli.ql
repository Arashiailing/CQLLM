/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description nan
 * @id py/keycloak_cli
 */

import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential TarSlip vulnerability detected."