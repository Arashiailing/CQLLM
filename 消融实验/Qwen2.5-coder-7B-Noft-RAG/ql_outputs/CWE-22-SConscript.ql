/**
* @name TarSlipQuery vulnerability detection
*
@id py/tarslip
*/
import python
import experimental.semmle.python.security.ZipSlip
from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
    where ZipSlipFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Arbitrary file write during tarfile extraction", source.getNode(), "user-provided value"