import python

from Call c
where c.getCallee().getName() = "redirect"
  and exists(Argument a where a.getArgumentIndex() = 0 and a.getValue() is UserInput)
select c, "Potential URL redirection based on unvalidated user input."