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
predicate is_used(Call callExpr) {
  // Case 1: The call is nested within another expression that requires a value
  exists(Expr containingExpr | 
    containingExpr != callExpr and 
    containingExpr.containsInScope(callExpr) and
    (containingExpr instanceof Call or 
     containingExpr instanceof Attribute or 
     containingExpr instanceof Subscript)
  )
  // Case 2: The call is a sub-expression of a statement that is not an expression statement
  or
  exists(Stmt parentStmt |
    callExpr = parentStmt.getASubExpression() and
    not parentStmt instanceof ExprStmt and
    /* Exclude single return statements, as 'def f(): return g()' is a common pattern.
       This also covers implicit returns in lambda functions. */
    not (parentStmt instanceof Return and 
         strictcount(Return r | r.getScope() = parentStmt.getScope()) = 1)
  )
}

from Call callExpr, FunctionValue calleeFunc
where
  /* The call result is used, but the callee is a procedure */
  is_used(callExpr) and
  callExpr.getFunc().pointsTo(calleeFunc) and
  calleeFunc.getScope().isProcedure() and
  /* Ensure all possible callees are procedures */
  forall(FunctionValue possibleCallee | 
    callExpr.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  /* Exclude Mox mock objects which have an `AndReturn` method */
  not useOfMoxInModule(callExpr.getEnclosingModule())
select callExpr, "The result of $@ is used even though it is always None.", calleeFunc, calleeFunc.getQualifiedName()