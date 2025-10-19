import python
import semmle.code.cpp.dataflow.DataFlow

from ForStmt, CallExpr, Parameter
where 
  ForStmt.getIterExpr() = CallExpr 
  and CallExpr.getMethodName() = "range" 
  and CallExpr.getArgument(0).getType().getName() = "int" 
  and CallExpr.getArgument(0) = Parameter 
  or 
  WhileStmt.hasConditionThatMayBeNull()
select ForStmt, "Potential uncontrolled resource consumption via infinite loop with user-controlled iteration count."