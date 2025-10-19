import python

from StringConcatenation sc, Expression e
where e instanceof Literal or e instanceof Name
  and (e instanceof Name and exists(Call c where c.getTarget() = e and c.getCallee().getName() = "input"))
  or (e instanceof Literal and e.getValue().startsWith("'"))
  and sc.toString().matches("SELECT|UPDATE|DELETE|INSERT")
select sc, "Potential SQL injection vulnerability via string concatenation."