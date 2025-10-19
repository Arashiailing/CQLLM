import python

from Call c
where c.getCallee().getName() in ("eval", "exec", "getattr", "setattr", "__import__")
select c, "Potential CWE-20: Improper Input Validation"