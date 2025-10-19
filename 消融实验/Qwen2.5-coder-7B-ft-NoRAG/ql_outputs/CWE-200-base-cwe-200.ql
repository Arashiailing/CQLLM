/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @id py/base-cwe-200
 */
import python
import semmle.python.security.dataflow.CleartextLoggingQuery

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is logged in cleartext."