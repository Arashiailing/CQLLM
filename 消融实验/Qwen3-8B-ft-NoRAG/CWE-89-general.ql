import py

from Call c, StringLiteral s, Variable v
where c.name = "+" and c.arguments = [s, v]
  and s.text matches /SELECT|UPDATE|DELETE|INSERT|CREATE/i
select c, "Potential SQL injection due to string concatenation in SQL query"