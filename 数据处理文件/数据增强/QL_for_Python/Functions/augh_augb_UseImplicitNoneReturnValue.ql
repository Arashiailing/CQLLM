/**
 * @name Use of the return value of a procedure
 * @description Identifies code that utilizes return values from procedures (functions returning None). 
 *              Such usage is problematic since the returned value (None) typically has no meaningful purpose.
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
 * Determines if a function call's result is utilized in the code.
 * A call is considered used if it participates in expressions requiring values,
 * excluding specific patterns like standalone returns.
 */
predicate is_used(Call funcCall) {
  // Case 1: Call is nested within value-requiring expressions
  exists(Expr parentExpr | 
    parentExpr != funcCall and 
    parentExpr.containsInScope(funcCall) and
    (parentExpr instanceof Call or 
     parentExpr instanceof Attribute or 
     parentExpr instanceof Subscript)
  )
  // Case 2: Call is part of non-expression statements
  or
  exists(Stmt containerStmt |
    funcCall = containerStmt.getASubExpression() and
    not containerStmt instanceof ExprStmt and
    /* Exclude single return statements (e.g., 'def f(): return g()') 
       and implicit lambda returns */
    not (containerStmt instanceof Return and 
         strictcount(Return r | r.getScope() = containerStmt.getScope()) = 1)
  )
}

from Call funcCall, FunctionValue calledFunction
where
  /* Call result is used but callee is a procedure */
  is_used(funcCall) and
  funcCall.getFunc().pointsTo(calledFunction) and
  calledFunction.getScope().isProcedure() and
  /* Verify all possible callees are procedures */
  forall(FunctionValue potentialCallee | 
    funcCall.getFunc().pointsTo(potentialCallee) | 
    potentialCallee.getScope().isProcedure()
  ) and
  /* Exclude Mox mock objects with `AndReturn` methods */
  not useOfMoxInModule(funcCall.getEnclosingModule())
select funcCall, "The result of $@ is used even though it is always None.", calledFunction, calledFunction.getQualifiedName()