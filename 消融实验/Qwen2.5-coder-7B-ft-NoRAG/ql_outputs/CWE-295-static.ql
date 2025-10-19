/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
 * @id py/static
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

from Http::Client::Request request,
     DataFlow::Node disablingNode,
     DataFlow::Node origin,
     string ending
where
  request.disablesCertificateValidation(disablingNode, origin) and
  if disablingNode = origin then
    ending = "."
  else
    ending = " by $@."

select request, "Request without certificate validation" + ending