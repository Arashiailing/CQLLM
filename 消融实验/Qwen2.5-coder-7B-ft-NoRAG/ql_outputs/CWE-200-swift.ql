/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/cleartext-logging-query
 */
import python
import semmle.python.security.dataflow.CleartextLoggingQuery

from CleartextLoggingQuery::PathNode source, CleartextLoggingQuery::PathNode sink
where CleartextLoggingQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is logged in cleartext."