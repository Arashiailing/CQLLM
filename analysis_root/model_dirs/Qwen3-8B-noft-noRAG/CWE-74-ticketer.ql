import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall, Argument, VariableDecl, CallExpr
where 
  MethodCall.getMethod().getName() = "render_template" and 
  MethodCall.getArguments().hasArgument(Argument.getArgValue().getValue() like "%{{%") or 
  CallExpr.getCallee().getName() = "Template.render" and 
  CallExpr.getArgs().exists(arg where arg.getValue().getStringLiteral().getValue() contains "{{")
select CallExpr, "Potential Server-Side Template Injection detected"