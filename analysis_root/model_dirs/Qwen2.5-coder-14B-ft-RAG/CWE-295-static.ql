/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/static
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

from Http::Client::Request req, DataFlow::Node node, DataFlow::Node orig, string end
where
  req.disablesCertificateValidation(node, orig) and
  if node = orig then end = "." else end = " by $@."
select req, "Making an HTTPS request without certificate verification" + end, orig,
  "user-provided input"