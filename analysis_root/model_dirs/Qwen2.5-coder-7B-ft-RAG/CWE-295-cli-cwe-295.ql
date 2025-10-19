/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/cli-cwe-295
 */

import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.Concepts
from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin, string ending
where
  request.disablesCertificateValidation(disablingNode, origin)
  and
  if disablingNode = origin then ending = "." else ending = " by $@."
select request, "Request disables SSL certificate verification" + ending, disablingNode,
  "Certificate verification is disabled here."