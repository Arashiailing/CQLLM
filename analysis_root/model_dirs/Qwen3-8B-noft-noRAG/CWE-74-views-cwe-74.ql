import python

/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @id py/views-cwe-74
 */

from method_call, Argument
where 
  method_call.name = "jinja2.Template.render" or 
  method_call.name = "jinja2.Environment.from_string" or 
  method_call.name = "django.template.loader.get_template" or 
  method_call.name = "django.template.Template"
  and (method_call.arguments.size() > 0)
  and (Argument.value = method_call.arguments[0])
  and exists(Source src, Flow flow | 
    src.location = Argument.location and 
    flow.source = src and 
    flow.sink = method_call.location)
select method_call, "Potential server side template injection: user-controlled data used in template rendering", severity=High