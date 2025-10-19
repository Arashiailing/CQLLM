import python

// Detect server-side template injection by identifying template creation with user-controlled data
from Call c, Argument arg
where (c.getCallee() = "jinja2.Template" or
       c.getCallee() = "django.template.loader.get_template" or
       c.getCallee() = "mako.template.Template" or
       c.getCallee() = "templatetags.templatetag.Template")
  and (arg.getValue() instanceof StringLiteral or
       exists(Variable v | c.getArguments().contains(v)))
select c, "Potential Server-Side Template Injection via template construction"