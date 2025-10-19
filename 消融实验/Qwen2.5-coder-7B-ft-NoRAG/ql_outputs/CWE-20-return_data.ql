/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
 * @id py/return_data
 */

import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected.", source.getNode(), "user-provided value"