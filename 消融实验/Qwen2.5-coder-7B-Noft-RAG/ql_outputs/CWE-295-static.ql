/**
* @name CWE-295: Improper Certificate Validation
*
@description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
*
@id py/static
*/
import python
import semmle.python.security.dataflow.RequestWithoutCertValidationQuery
from RequestWithoutCertValidationQuery::PathNode source, RequestWithoutCertValidationQuery::PathNode sink
    where RequestWithoutCertValidationQuery::flowPath(source, sink)
    select sink.getNode(), source, sink, "Request made without certificate validation", source.getNode(), "user-provided value"