import python

/**
 * @name CWE-918: Server-Side Request Forgery
 * @description Detects potential SSRF vulnerabilities by identifying network request calls with user-controlled URLs.
 */
from Call call
where (
    (call.getSelector().getName() = "get" and
     call.getArgument(0).getParameterName() = "url") or
    (call.getSelector().getName() = "post" and
     call.getArgument(0).getParameterName() = "url"))
select call, "Potential SSRF vulnerability: Network request using user-controlled URL parameter."