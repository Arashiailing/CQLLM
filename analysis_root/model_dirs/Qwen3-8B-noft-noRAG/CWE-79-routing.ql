import python

from CallExpr ce, StringLiteral sl, MethodCall mc
where ce.getCallee().getName() = "write" or ce.getCallee().getName() = "print"
  and ce.getArgument(0) = sl
  and mc.getName() = "get"
  and mc.getQualifier().getName() = "request"
  and sl.getValue().contains(mc.getArg(0).getValue())
select ce, "Potential reflected XSS due to direct use of unescaped user input in HTTP response."