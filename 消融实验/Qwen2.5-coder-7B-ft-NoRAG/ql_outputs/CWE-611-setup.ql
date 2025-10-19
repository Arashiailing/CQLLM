/**
 * @name XML external entity expansion
 * @description Parsing user input as an XML document with external
 *              entity expansion is vulnerable to XXE attacks.
 * @id py/setup
 */

import python
import semmle.python.security.dataflow.XxeQuery
import XxeFlow::PathGraph

from XxeFlow::PathNode source, XxeFlow::PathNode sink
where XxeFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XML parsing depends on a $@ without guarding against external entity expansion."