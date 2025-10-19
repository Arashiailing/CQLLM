/**
 * @name CWE-295: Improper Certificate Validation
 * @id py/client-cwe-295
 */
import python
private import semmle.python.dataflow.new.DataFlow

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin
where request.disablesCertificateValidation(disablingNode, origin)
select request, "Request without certificate validation detected", disablingNode, "disabled by", origin