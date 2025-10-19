import python

from CallExpr call, StringLiteral lit, Variable var
where 
  call.getMethod().getName() = "print" and 
  lit.toString() contains var.getName() and 
  (var.getType().toString() = "str" or var.getType().toString() = "bytes") and 
  not exists (var.getType().getQualifiedName() = "html.entities.EntityEncoder")
select call, "Potential reflected XSS vulnerability due to direct output of unescaped user input"