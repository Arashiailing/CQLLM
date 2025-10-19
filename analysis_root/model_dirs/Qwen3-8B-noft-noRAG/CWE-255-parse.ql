import python

from Call call, FunctionDecl func
where 
  func.getName() = "md5" or 
  func.getName() = "sha1" or 
  func.getName() = "sha" and func.getParameters().size() = 0
  and exists(
    call.getCallee() = func and 
    call.getLocation().getFile().getShortName() like "%auth%" or 
    call.getLocation().getFile().getShortName() like "%password%"
  )
select call, "Use of weak hash algorithm for sensitive data (CWE-255)"