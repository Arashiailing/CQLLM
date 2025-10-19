import python

from Call c
where c.getCallee().getName() = "check_password" and c.getArg(0).getValue() = "user_input" and c.getArg(1).getValue() = "plain_text"
select c, "Potential CWE-287: Improper Authentication"