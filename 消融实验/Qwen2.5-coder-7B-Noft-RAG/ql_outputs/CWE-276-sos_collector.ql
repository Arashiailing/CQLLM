/**
* @name CWE-276: TarSlipQuery
*
@description nan
*
@id py/sos_collector
*/
import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph
from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
    where TarSlipFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This tarfile extraction depends on a $@.", source.getNode(), "user-provided value"