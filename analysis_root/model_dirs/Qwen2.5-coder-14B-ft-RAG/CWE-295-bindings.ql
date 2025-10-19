/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @id py/request-without-cert-validation
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-295
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin, string ending
where
  request.disablesCertificateValidation(disablingNode, origin) and
  if disablingNode = origin then ending = "." else ending = " by $@."
select request.getRequest(),
  "The request at $@ performs certificate validation" + ending, disablingNode,
  disablingNode.toString()