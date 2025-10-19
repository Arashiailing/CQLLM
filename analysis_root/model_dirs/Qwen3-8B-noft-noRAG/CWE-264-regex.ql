import python
import semmle.code.cpp.dataflow.DataFlow

from Call call, Argument arg, Expr expr
where 
  call.getMethod().getName() = "compile" and
  call.getCallee().getModule() = "re" and
  arg.getIndex() = 0 and
  arg.getExpr() = expr and
  expr.hasUserInput()
select expr, "Potential Regex Injection: User input is directly used in a regular expression pattern."