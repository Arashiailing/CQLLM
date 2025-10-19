/**
* @name TarSlipQuery
* @kind path-problem
* @problem.severity error
* @security-severity 7.5
* @precision medium
*
@id py/tarslip-query
*
@tags security
*/
import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph
from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
    where ZipSlipFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Arbitrary file write during tarfile extraction."