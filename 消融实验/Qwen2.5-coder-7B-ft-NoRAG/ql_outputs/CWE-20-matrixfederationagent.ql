/**
 * @name CWE-20: Improper Input Validation
 * @id py/matrixfederationagent
 */

import python
import semmle.python.security.dataflow.InputValidationQuery

from DataFlow::Node source, DataFlow::Node sink
where InputValidationQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Input validation is missing or incorrect."