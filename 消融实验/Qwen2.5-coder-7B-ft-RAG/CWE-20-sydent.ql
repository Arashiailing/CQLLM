/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision high
 * @id py/sydent
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import ServerSideRequestForgeryFlow::PathGraph
from ServerSideRequestForgeryFlow::PathNode source, ServerSideRequestForgeryFlow::PathNode sink
where ServerSideRequestForgeryFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This request originates from a $@", source.getNode(), "user-supplied value"