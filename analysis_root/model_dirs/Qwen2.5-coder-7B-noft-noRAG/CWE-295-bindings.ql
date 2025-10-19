/**
 * @name Request without certificate validation
 * @description Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/request-without-cert-validation
 * @tags security
 *       external/cwe/cwe-295
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin
where
  request.disablesCertificateValidation(disablingNode, origin)
select request, "Request without certificate validation at $@.", disablingNode, "this location"