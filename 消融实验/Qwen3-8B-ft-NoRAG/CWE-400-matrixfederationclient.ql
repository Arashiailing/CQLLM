import python

/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/matrixfederationclient
 */
from Call call, Variable var, WhileStmt whileStmt
where call.getKind() = "call" and call.getFunctionName() = "input"
  and var = call.getArgument(0)
  and whileStmt.getCondition().getExpression() = var
select whileStmt, "Potential uncontrolled resource consumption via unbounded loop condition"