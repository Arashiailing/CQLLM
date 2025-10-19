/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision high
 * @id py/base-cwe-200
 */

import python
import CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This log entry exposes a $@.", source.getNode(), "sensitive value"