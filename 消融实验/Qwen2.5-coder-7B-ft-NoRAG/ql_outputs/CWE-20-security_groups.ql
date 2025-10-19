/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
 * @id py/security-groups
 */

import python
import semmle.python.security.dataflow.InputValidationQuery
import InputValidationFlow::PathGraph

from InputValidationFlow::PathNode source, InputValidationFlow::PathNode sink
where InputValidationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Input validation is missing or incorrect for a $@.", source.getNode(), "user-supplied data"