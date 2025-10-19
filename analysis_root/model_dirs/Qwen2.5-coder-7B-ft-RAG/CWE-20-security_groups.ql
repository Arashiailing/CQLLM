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
 * @id py/security_groups
 */

import python
import semmle.python.security.dataflow.SecurityGroupQuery
import SecurityGroupFlow::PathGraph

from SecurityGroupFlow::PathNode source, SecurityGroupFlow::PathNode sink
where SecurityGroupFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Security group depends on a $@.", source.getNode(),
  "user-provided value"