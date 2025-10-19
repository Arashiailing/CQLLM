import python
import semmle.code.cpp.dataflow.DataFlow

from Variable v, FunctionCall fc, CallExpr ce
where 
  fc.getName() = "urlparse.urljoin" or 
  fc.getName() = "urllib.parse.urljoin" or 
  fc.getName() = "urllib.request.urlopen" or 
  fc.getName() = "requests.get" or 
  fc.getName() = "requests.post" or 
  fc.getName() = "http.client.HTTPConnection"
  and ce.hasArg(0, v)
  and v.isSource()
select v, "Potential URL redirection based on unvalidated user input (CWE-601)"