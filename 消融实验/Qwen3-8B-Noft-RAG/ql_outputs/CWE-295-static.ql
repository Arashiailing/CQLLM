/**
 * @name CWE-295: Improper Certificate Validation
 * @id py/static
 */
import python
private import semmle.python.dataflow.new.DataFlow

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin
where request.disablesCertificateValidation(disablingNode, origin)
  and (disablingNode = origin or exists(DataFlow::Edge edge | edge.getSource() = origin and edge.getTarget() = disablingNode))
select request, "Request without certificate validation may allow man-in-the-middle attacks."