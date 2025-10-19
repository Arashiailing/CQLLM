import python

/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @id py/_newclient
 */
from Call call, StringLiteral str_lit, Argument arg
where 
  (call.getSelector().getName() = "render_template_string" or 
   call.getSelector().getName() = "render_template" or 
   call.getSelector().getName() = "Template.render") and 
  arg.isArgumentOf(call) and 
  arg.getValue() = str_lit and 
  str_lit.getValue().contains("{{") or 
  call.getSelector().getName() = "format" and 
  exists(Argument arg2 | arg2.isArgumentOf(call) and arg2.getValue().isUserInput())
select call, "Potential server-side template injection vulnerability detected"