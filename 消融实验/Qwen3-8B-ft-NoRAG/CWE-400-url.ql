import python

from RegexLiteral r, Pattern p
where r.pattern = p
  and p.hasPolynomialReDoS
select r, "This regular expression may be vulnerable to Polynomial ReDoS due to potential resource consumption."