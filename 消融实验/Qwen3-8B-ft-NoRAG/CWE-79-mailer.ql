import python

from Call call, StringLiteral strLit, Argument arg
where (call.getFunctionName() = "format" and call.getArgument(0) = strLit and arg = call.getArgument(1) and arg.getType().getName() = "str")
   or (call.getFunctionName() = "print" and call.getArgument(0).getExpression().toString().matches("<.*>.*"))
select call, "Potential reflected XSS due to direct output of unescaped user input."