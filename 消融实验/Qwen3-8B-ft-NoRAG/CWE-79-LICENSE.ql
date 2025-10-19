import python

from Call call, Call getCall, StringLiteral string, Expr expr
where call.getMethod().getName() = "format" and
      getCall.getMethod().getName() = "get" and
      getCall.getArgument(0).getValue() = "param" and
      expr = getCall.getArgument(1) and
      call.getArgument(0).getValue() = string.getValue()
select expr, "Potential reflected XSS due to unescaped user input."