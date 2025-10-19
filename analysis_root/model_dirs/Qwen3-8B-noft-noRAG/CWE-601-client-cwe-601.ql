import python

from Call c, Argument a
where 
  c.getCallee().getName() =~ /^.*redirect$/i
  and a = c.getArgs()[0]
  and a.getValue() instanceof StringLiteral
  and not a.getValue().getValue() matches /^https?:\/\//i
select c, "Potential URL redirection with unvalidated input"