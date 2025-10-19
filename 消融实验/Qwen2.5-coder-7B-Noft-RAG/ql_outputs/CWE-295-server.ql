/**
* @name CWE-295: Improper Certificate Validation
*
@description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
*
@id py/server
*/
import python
import semmle.python.security.dataflow.RequestWithoutValidationQuery
import semmle.python.Concepts
from HttpRequest req, DataFlow::Node disablingNode, DataFlow::Node origin, string ending
    where req.disablesCertificateValidation(disablingNode, origin)
    and if disablingNode = origin then ending = "." else ending = " by $@."
    select req, "Request without certificate validation" + ending