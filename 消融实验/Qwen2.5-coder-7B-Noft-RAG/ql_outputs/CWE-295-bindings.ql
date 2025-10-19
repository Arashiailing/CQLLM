/**
* @name CWE-295: Improper Certificate Validation
*
@description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
*
@id py/bindings
*/
import python
import semmle.python.security.dataflow.RequestWithoutCertValidationQuery
import RequestWithoutCertValidationFlow::PathGraph
from RequestWithoutCertValidationFlow::PathNode source, RequestWithoutCertValidationFlow::PathNode sink
    where RequestWithoutCertValidationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Request made without certificate validation.", source.getNode(), "user-provided input"