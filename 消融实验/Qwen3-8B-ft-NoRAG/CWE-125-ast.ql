import py

from SubscriptExpr s, CallExpr c
where s.getIndex() = c.getArg(0)
  and c.getCallee().getName() = "input"
  and s.getBase().getType().isListOrString()
select s, "Potential CWE-125: Out-of-bounds read via user-controlled index"