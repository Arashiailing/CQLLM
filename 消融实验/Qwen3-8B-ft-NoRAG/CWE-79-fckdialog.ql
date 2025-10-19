import py

from Call c, StringLiteral s, Variable v
where c.getTarget() = py.Function("print")
  and c.getArgument() = s + v
select c, "Potential reflected XSS due to direct output of user input."