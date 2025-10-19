import py

from Call c
where c.getFunction().getName() = "render_template"
  and c.getArgument(0).getValue() is StringLiteral
  and c.getArgument(0).getValue().getValue().matches("{{.*?}}")
select c, "Potential Server Side Template Injection in template name."