import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.python.PythonStrings

/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 * @description Detects potential SSRF vulnerabilities by identifying network requests using user-controlled inputs in URLs.
 */
predicate isUserControlledInput(String s) {
  exists(Param param |
    param.getName() = "url" or
    param.getName() = "uri" or
    param.getName() = "path" or
    param.getName() = "request_url" or
    param.getName() = "target"
    and param.getOrigin().isFromUserInput()
  ) where s = param.getValue()
}

from Call call, String urlArg
where 
  call.getTarget() = "requests.get" or
  call.getTarget() = "requests.post" or
  call.getTarget() = "urllib.request.urlopen" or
  call.getTarget() = "http.client.HTTPConnection.request" or
  call.getTarget() = "socket.socket.connect"
  and urlArg = call.getArgument(0)
  and isUserControlledInput(urlArg)
select urlArg, "Potential SSRF vulnerability: User-controlled input used in URL construction."