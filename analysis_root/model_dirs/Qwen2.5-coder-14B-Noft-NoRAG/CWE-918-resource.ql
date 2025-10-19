import python

/**
 * CWE-918: Server-Side Request Forgery (SSRF)
 */
from Call call, StringLiteral url
where call.getCallee().getName() = "requests.get" and
      call.getArgument(0) = url and
      url.getValue().matches("%.*%")
select call, "This call to requests.get may be vulnerable to SSRF because the URL is partially user-controlled."