import python

from Call c, StringLiteral s1, Var v, StringLiteral s2
where c.getTarget().getName() = "execute" and c.getArg(0) = s1 + v + s2 and v is UserInput
select c, "Potential SQL injection via string concatenation in execute call"