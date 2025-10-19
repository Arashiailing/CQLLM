/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/uncontrolled-resource-consumption
 * @tags security
 *       external/cwe/cwe-400
 */

import python
import semmle.python.Concepts

from Http::Client::Request req, string method, int n
where
  // Check if the request uses a POST method
  method = "POST" and
  // Verify the number of parameters exceeds the maximum allowed limit
  n = count(Http::Client::PostParam param | param.getRequest() = req)
  and
  n > 20
select req, "Uncontrolled consumption due to too many '" + method.toLowerCase() + "' parameters (" + n.toString() + ")"