import python
from Call c, Argument a
where c.getCallee().getName() = "print"
  and a.getArgumentPosition() = 0
  and a.getKind() = "Variable"
  and a.getName() = "user_input"
select c, "Potential Reflected XSS: User input is directly output without escaping"