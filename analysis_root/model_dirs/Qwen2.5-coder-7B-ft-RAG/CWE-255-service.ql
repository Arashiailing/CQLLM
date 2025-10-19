/**
 * @name CWE CATEGORY: Credentials Management Errors
 * @description nan
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/service
 */

import python
import semmle.python.Concepts
import semmle.python.ApiGraphs

from ApiNode node
where node.isServiceEndpoint()
select node, "This service endpoint is exposed over a network interface."