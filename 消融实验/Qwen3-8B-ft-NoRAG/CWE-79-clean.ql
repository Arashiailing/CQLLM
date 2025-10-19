import semmle.code.python.Python

from Call c, Argument a
where c.getExpression().toString() = "print" and a.getArgument().toString() = "user_input"
select c, "Potential reflected XSS vulnerability."