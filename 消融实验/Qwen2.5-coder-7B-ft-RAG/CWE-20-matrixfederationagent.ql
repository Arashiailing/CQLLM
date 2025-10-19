/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/matrixfederationagent
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.MatrixFederationAgentQuery
import MatrixFederationAgentFlow::PathGraph
from MatrixFederationAgentFlow::PathNode source, MatrixFederationAgentFlow::PathNode sink
where MatrixFederationAgentFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Matrix Federation Agent sends a request to a $@", source,
  "unauthenticated server"