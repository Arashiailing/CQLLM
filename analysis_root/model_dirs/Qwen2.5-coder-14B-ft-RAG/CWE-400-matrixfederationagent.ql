/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @id py/matrixfederationagent
 * @problem.severity error
 * @precision medium
 * @tags security
 *       external/cwe/cwe-400
 */

import python
import MatrixFederationAgentQuery
import MatrixFederationAgentFlow::PathGraph

from
  MatrixFederationAgentFlow::PathNode source,
  MatrixFederationAgentFlow::PathNode sink,
  MatrixFederationAgentClient client
where
  MatrixFederationAgentFlow::flowPath(source, sink) and
  client = sink.getNode().(MatrixFederationAgentClient)
select
  sink.getNode(), source, sink, "Call to " + client.toString() + "."