import py

from Call c
where c.getCallee().getName() = "input"
select c, "Potential CWE-20: Improper Input Validation"