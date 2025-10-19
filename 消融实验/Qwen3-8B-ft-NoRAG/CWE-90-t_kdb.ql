import python

from StringLiteralConcatenation c
where c.getConcatenatedStrings().size() > 1
  and c.getString().matches("^\(.*\)$")
select c, "Potential LDAP injection via LDAP query string concatenation."