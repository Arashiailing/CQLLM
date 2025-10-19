/**
 * @name TarSlipQuery
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @id py/TarSlipQuery
 */

import python
import experimental.semmle.python.security.ZipSlip

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"