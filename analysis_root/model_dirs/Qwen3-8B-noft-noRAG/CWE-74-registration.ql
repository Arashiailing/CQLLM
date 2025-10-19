import python

from Call c, Argument a
where c.getTarget().getName() = "render_template_string"
  and a.getValue() instanceof String
  and a.getValue().getValue() = some UserInput()
select c, "Potential Server Side Template Injection via render_template_string with untrusted input"