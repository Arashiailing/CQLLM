/**
 * @name CWE-20: Improper Input Validation
 * @id py/mockobject
 */

import python
import semmle.python.security.dataflow.InputValidationQuery

from InputValidationFlow::PathNode source, InputValidationFlow::PathNode sink
where InputValidationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input validation is missing or incorrect."