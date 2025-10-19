/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@description Logging sensitive information in clear text exposes it to unauthorized actors.
*
@id py/cleartext-logging-query
*/
import python
import semmle.python.security.dataflow.SensitiveDataLeakageQuery
import SensitiveDataLeakageFlow::PathGraph
from SensitiveDataLeakageFlow::PathNode source, SensitiveDataLeakageFlow::PathNode sink
    where SensitiveDataLeakageFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information is logged in clear text.", source.getNode(), "sensitive data"