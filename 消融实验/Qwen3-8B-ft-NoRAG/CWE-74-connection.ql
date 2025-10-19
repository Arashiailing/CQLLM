import python

/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @id py/connection
 */

from TemplateCall, CallExpr, MethodCall, Parameter
where
  TemplateCall = MethodCall
  and TemplateCall.getTarget().getName() = "render"
  and TemplateCall.getArgument(0).getType().getName() = "str"
  and exists(Parameter p where p.getArgument() = TemplateCall.getArgument(0) and p.isUserInput())
select TemplateCall, "Potential Server Side Template Injection: User-controlled data is directly used in template rendering."