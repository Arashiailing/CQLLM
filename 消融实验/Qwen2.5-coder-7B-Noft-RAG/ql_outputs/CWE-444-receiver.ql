/**
* @name CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
*
@description This query identifies potential instances of HTTP request/response smuggling vulnerabilities.
*
@id py/receiver
*
@tags security
*/
import python
import semmle.python.http.HTTPRequestSmuggling
from HTTPRequestSmuggling::PotentialVulnerability vuln
    select vuln, "Potential HTTP Request/Response Smuggling vulnerability detected."