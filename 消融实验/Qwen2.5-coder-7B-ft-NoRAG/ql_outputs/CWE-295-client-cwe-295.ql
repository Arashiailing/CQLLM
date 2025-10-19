/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
 * @id py/client-cwe-295
 */
import python
import semmle.python.dataflow.new.DataFlow

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin, string ending
where
  request.disablesCertificateValidation(disablingNode, origin) and
  if disablingNode = origin then ending = "." else ending = " by $@."
select request, "This request may run without certificate validation because $@" + ending, disablingNode, "it is disabled", origin, "this value"