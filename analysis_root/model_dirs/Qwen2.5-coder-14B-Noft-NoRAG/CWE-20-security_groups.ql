import python

/**
 * This query detects CWE-20: Improper Input Validation in Python code.
 * It looks for functions that receive input but do not validate it properly.
 */

from Function func, Call call, Expr inputExpr
where func.hasParameter(inputExpr) and
      not exists(Expr validationExpr |
          validationExpr instanceof IfExpr and
          validationExpr.getCondition() instanceof BinaryExpr and
          validationExpr.getCondition().getLeftOperand() = inputExpr
      )
select func, "This function does not validate input properly: " + func.getName()