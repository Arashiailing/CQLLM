import python
import semmle.code.java.types.Types

from Call call, Argument arg, Expr expr
where 
  call.getTarget().getName() = "get" and 
  call.getTarget().getModule() = "requests" and 
  arg.getPosition() = 0 and 
  expr = arg.getArgument() and 
  expr.isDynamic()
select expr, "Potential URL redirection from unvalidated user input"