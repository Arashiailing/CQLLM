import python

from StringLiteral s, Call c
where (c.getSelector().getName() = "input" and c.getArgument(0).getType().getName() = "str") or
      (c.getSelector().getName() = "==" and c.getArguments().size() = 2 and c.getArgument(0).getType().getName() = "str" and c.getArgument(1) = s)
select c, "Potential CWE-287: Improper authentication detected"