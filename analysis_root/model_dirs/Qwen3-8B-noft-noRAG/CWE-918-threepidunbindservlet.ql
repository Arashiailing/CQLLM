import python

/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 * @description Detects potential SSRF vulnerabilities where user-controlled input is used in network requests without proper validation.
 */
from Call call, Argument arg
where 
  call.getCallee().getName() = "urllib.request.urlopen" or 
  call.getCallee().getName() = "requests.get" or 
  call.getCallee().getName() = "requests.post" or 
  call.getCallee().getName() = "http.client.HTTPConnection"
  and arg.getArgumentIndex() = 0
  and exists(Argument srcArg |
    call.getSourceArgs().has(srcArg) and 
    srcArg.isFromUserInput()
  )
select call, "Potential SSRF vulnerability: User-controlled input is used in a network request without sufficient validation."