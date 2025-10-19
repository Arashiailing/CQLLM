/**
 * @name TarSlipQuery
 * @kind path-problem
 * @id py/archiver
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "TarSlip vulnerability detected: Extraction of tarfile from $@ to a potentially untrusted source $@.", source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()