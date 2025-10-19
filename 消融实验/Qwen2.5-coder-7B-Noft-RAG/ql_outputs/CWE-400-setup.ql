/**
* @name CWE-400: TarSlipQuery
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
*
@id py/tarslip
* @problem.severity error
* @security-severity 7.5
* @precision medium
*
@tags security * external/cwe/cwe-400
*/
import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph
from TarSlipFlow::PathNode source, TarSlipFlow::PathNode sink
    where TarSlipFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"