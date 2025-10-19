/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
 * @id py/registerservlet
 */

import python
import semmle.python.security.dataflow.SqlInjectionQuery

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This SQL query depends on a $@.", source.getNode(), "user-provided value"