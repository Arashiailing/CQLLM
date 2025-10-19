import python

from MethodCall mc, StringLiteral sl
where
  mc.getMethodName() = "execute" and
  mc.getArgument(0) instanceof String and
  sl.getValue() = mc.getArgument(0).getValue() and
  sl.getValue().contains("'") and
  not (sl.getValue().startsWith("SELECT") or sl.getValue().startsWith("INSERT"))
select mc.getLocation(), "Potential SQL injection vulnerability due to direct string concatenation in execute call"