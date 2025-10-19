/**
 * @name Use of the return value of a procedure
 * @description Detects usage of return values from procedures (functions that return None). 
 *              Such usage is misleading since the returned value (None) typically has no meaningful purpose.
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
 * Determines if a call expression's result is utilized in the code.
 * A call is considered used if it is part of another expression or statement
 * that expects a value, excluding certain common patterns like standalone returns.
 */
predicate is_used(Call funcCall) {
  // Case 1: The call is nested within another value-requiring expression
  exists(Expr parentExpr | 
    parentExpr != funcCall and 
    parentExpr.containsInScope(funcCall) and
    (parentExpr instanceof Call or 
     parentExpr instanceof Attribute or 
     parentExpr instanceof Subscript)
  )
  // Case 2: The call is a sub-expression in non-expression statements
  or
  exists(Stmt stmtParent |
    funcCall = stmtParent.getASubExpression() and
    not stmtParent instanceof ExprStmt and
    /* Exclude single return statements (common pattern like 'def f(): return g()').
       Also covers implicit returns in lambda functions. */
    not (stmtParent instanceof Return and 
         strictcount(Return r | r.getScope() = stmtParent.getScope()) = 1)
  )
}

from Call funcCall, FunctionValue calledFunction
where
  /* The call result is used, but the callee is a procedure */
  is_used(funcCall) and
  funcCall.getFunc().pointsTo(calledFunction) and
  calledFunction.getScope().isProcedure() and
  /* Ensure all possible callees are procedures */
  forall(FunctionValue possibleCallee | 
    funcCall.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  /* Exclude Mox mock objects with `AndReturn` method */
  not useOfMoxInModule(funcCall.getEnclosingModule())
select funcCall, "The result of $@ is used even though it is always None.", calledFunction, calledFunction.getQualifiedName()