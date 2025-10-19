import python

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 */
from MethodDeclaration method, StringLiteral str, Call call
where 
  (method.getName() = "log" or method.getName() = "info" or method.getName() = "debug") 
  and 
  (call.getTarget().getFullyQualifiedName() = "logging.Logger.log" or 
   call.getTarget().getFullyQualifiedName() = "logging.Logger.info" or 
   call.getTarget().getFullyQualifiedName() = "logging.Logger.debug")
  and 
  (str.getValue() contains "password" or 
   str.getValue() contains "secret" or 
   str.getValue() contains "token" or 
   str.getValue() contains "key" or 
   str.getValue() contains "credentials")
select call, "Potential exposure of sensitive information in log output."