import py

from CallExpr c
where c.getCallee().getName() in ["get", "post"]
  and c.getArgByName("verify") is not null
  and c.getArgByName("verify").getValue() = false
select c, "Improper certificate validation in request."