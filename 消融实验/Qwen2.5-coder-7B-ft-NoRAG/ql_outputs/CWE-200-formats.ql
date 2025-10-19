/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/formats
 */

import python
import semmle.python.security.dataflow.SensitiveDataLeakageQuery
import SensitiveDataLeakageFlow::PathGraph

from SensitiveDataLeakageFlow::PathNode source, SensitiveDataLeakageFlow::PathNode sink
where SensitiveDataLeakageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is logged in cleartext."