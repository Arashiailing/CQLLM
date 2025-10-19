/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/context
 */
import python
import semmle.python.security.dataflow.SensitiveDataFlow

from SensitiveDataFlow::PathNode source, SensitiveDataFlow::PathNode sink
where SensitiveDataFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information stored in cleartext"