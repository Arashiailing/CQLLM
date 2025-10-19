import python

/**
 * Detects SQL injection vulnerabilities where user-controlled inputs are directly concatenated into SQL queries.
 */
from CallExpr call, StringLiteral startStr, StringLiteral endStr, VariableDecl userInputVar
where call.getTarget().getName() = "execute"
  and call.getArgument(0) instanceof BinaryExpr
  and ((BinaryExpr) call.getArgument(0)).getLeftOperand() = startStr
  and ((BinaryExpr) call.getArgument(0)).getRightOperand() instanceof BinOp
  and ((BinOp) ((BinaryExpr) call.getArgument(0)).getRightOperand()).getOperator() = "+"
  and ((BinOp) ((BinaryExpr) call.getArgument(0)).getRightOperand()).getRightOperand() = userInputVar
  and userInputVar.getType().isString()
select call, "Potential SQL injection vulnerability detected via direct string concatenation in SQL query."