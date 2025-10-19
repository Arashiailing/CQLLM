import py

from Call c
where c.getKind() = "Call" and c.getExpression().getName() = "input"
select c, "Potential CWE-20: Improper Input Validation"