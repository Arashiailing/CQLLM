/**
* @name CWE-295: Improper Certificate Validation
*
@description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
*
@id py/consumer
*/
import python
import semmle.python.security.dataflow.RequestWithoutValidationQuery
import RequestWithoutValidationFlow::PathGraph
from RequestWithoutValidationFlow::PathNode source, RequestWithoutValidationFlow::PathNode sink
    where RequestWithoutValidationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Request made without certificate validation by $@.", source.getNode(), "user-supplied input"