import python

from RegexLiteral r, Call c
where
  c.getTarget() = r.getStr() and
  (r.getValue().matches(".*\$$.*$\$") or
   r.getValue().matches(".*\*{2,}.*" ) or
   r.getValue().matches(".+\+{2,}.*" ) or
   r.getValue().matches(".*$\{2,}.*" ) or
   r.getValue().matches(".+?${2,}.*"))
select c, "Potential Polynomial ReDoS vulnerability due to complex regex pattern"