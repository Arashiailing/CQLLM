/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
 * @id py/tcp
 */

import python
import semmle.python.security.dataflow.LoggingQuery

from LoggingFlow::PathNode source, LoggingFlow::PathNode sink
where LoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation leads to cleartext logging."