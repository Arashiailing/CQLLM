import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg, StringLiteral urlPart
where 
  call.getCallee().getName() = "urllib.request.urlopen" or 
  call.getCallee().getName() = "requests.get" or 
  call.getCallee().getName() = "requests.post"
  and arg.getArgNum() = 0
  and urlPart.getValue() instanceof StringLiteral
  and urlPart.getValue().getContents() matches /(?:https?:\/\/)?(127\.0\.0\.1|localhost|(?:10|172\.(?:1[6-9]|2[0-9]{2})|192\.168)\.\d+\.\d+|\[::1\])/i
select call.getLocation(), "Potential SSRF vulnerability detected - unvalidated internal network request"