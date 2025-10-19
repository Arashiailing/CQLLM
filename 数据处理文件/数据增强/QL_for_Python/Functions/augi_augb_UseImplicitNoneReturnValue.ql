/**
 * @name Use of the return value of a procedure
 * @description Identifies instances where return values from procedures (functions returning None) 
 *              are utilized. Such usage is misleading since None typically lacks meaningful purpose.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

/**
 * Determines whether a call expression's result is utilized in the code.
 * A call is considered used if it participates in expressions or statements 
 * expecting a value, excluding common patterns like standalone returns.
 */
predicate is_result_utilized(Call callNode) {
  // Case 1: Call nested within value-requiring expressions
  exists(Expr parentExpr | 
    parentExpr != callNode and 
    parentExpr.containsInScope(callNode) and
    (parentExpr instanceof Call or 
     parentExpr instanceof Attribute or 
     parentExpr instanceof Subscript)
  )
  // Case 2: Call is sub-expression in non-expression statements
  or
  exists(Stmt parentStatement |
    callNode = parentStatement.getASubExpression() and
    not parentStatement instanceof ExprStmt and
    /* Exclude single returns (e.g., `def f(): return g()`) and implicit lambda returns */
    not (parentStatement instanceof Return and 
         strictcount(Return r | r.getScope() = parentStatement.getScope()) = 1)
  )
}

from Call callNode, FunctionValue calledFunction
where
  /* Call result is used but callee is a procedure */
  is_result_utilized(callNode) and
  callNode.getFunc().pointsTo(calledFunction) and
  calledFunction.getScope().isProcedure() and
  /* Ensure all possible callees are procedures */
  forall(FunctionValue possibleCalledFunction | 
    callNode.getFunc().pointsTo(possibleCalledFunction) | 
    possibleCalledFunction.getScope().isProcedure()
  ) and
  /* Exclude Mox mock objects with `AndReturn` method */
  not useOfMoxInModule(callNode.getEnclosingModule())
select callNode, "The result of $@ is used even though it is always None.", calledFunction, calledFunction.getQualifiedName()