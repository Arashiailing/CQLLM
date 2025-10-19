import python

/**
 * @name CWE-295: Improper Certificate Validation
 * @description Detects requests made without certificate validation
 */
from CallExpr call
where 
  (call.getCallee().getQualifiedName() = "requests.get" or 
   call.getCallee().getQualifiedName() = "requests.post" or 
   call.getCallee().getQualifiedName() = "requests.put" or 
   call.getCallee().getQualifiedName() = "requests.patch" or 
   call.getCallee().getQualifiedName() = "requests.delete") and
  not exists (call.getArgs() as arg where arg.getName() = "verify")
select call, "This request lacks certificate validation (missing'verify' parameter)"