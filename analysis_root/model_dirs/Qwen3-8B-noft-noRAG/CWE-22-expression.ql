import semmle.code.cpp.Expressions
import semmle.code.cpp.ControlFlow

from FunctionCall, Parameter, Expression
where 
  FunctionCall.getName() = "join" and 
  FunctionCall.getParameters()[0] instanceof Parameter and 
  Parameter.getValue().getUnderlyingExpression() instanceof Expression and 
  Expression.getText().matches("\\$\\{.*?\\}") or 
  Expression.getText().contains("..") or 
  Expression.getText().contains("~")
select FunctionCall, "Potential path injection vulnerability detected"