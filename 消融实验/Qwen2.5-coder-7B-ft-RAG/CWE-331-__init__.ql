/**
 * @name Remote code execution
 * @description Identifies calls to functions that execute untrusted input as code.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/rce
 * @tags security
 *       experimental
 *       external/cwe/cwe-94
 */

import python
import experimental.semregr.security.dataflow.RceQuery
import RceFlow::PathGraph

from RceFlow::PathNode source, RceFlow::PathNode sink
where RceFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Executing $@ could evaluate to a code object.", source.getNode(), "untrusted input"