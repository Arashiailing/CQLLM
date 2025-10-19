import python

/**
 * This query detects CWE-476: NULL Pointer Dereference.
 * It finds instances where a pointer is dereferenced without checking if it is NULL.
 */

from BinaryOperation bo
where bo.getOperator() = "==" and bo.getLeftOperand() instanceof NullLiteral and bo.getRightOperand() instanceof VariableAccess
select bo, "Potentially dereferencing a NULL pointer."

from BinaryOperation bo
where bo.getOperator() = "!=" and bo.getLeftOperand() instanceof NullLiteral and bo.getRightOperand() instanceof VariableAccess
select bo, "Potentially dereferencing a NULL pointer."

from BinaryOperation bo
where bo.getOperator() = "==" and bo.getRightOperand() instanceof NullLiteral and bo.getLeftOperand() instanceof VariableAccess
select bo, "Potentially dereferencing a NULL pointer."

from BinaryOperation bo
where bo.getOperator() = "!=" and bo.getRightOperand() instanceof NullLiteral and bo.getLeftOperand() instanceof VariableAccess
select bo, "Potentially dereferencing a NULL pointer."