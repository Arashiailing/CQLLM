/**
 * @name CWE-20: Improper Input Validation
 * @id py/packet
 */

import python
import semmle.python.security.dataflow.InputValidationQuery
import InputValidationFlow::PathGraph

from InputValidationFlow::PathNode source, InputValidationFlow::PathNode sink
where InputValidationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input validation issue detected.", source.getNode(), "user-supplied input"