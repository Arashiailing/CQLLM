/**
 * @name Use of the return value of a procedure
 * @description The return value of a procedure (a function that does not return a value) is used. This is confusing to the reader as the value (None) has no meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Predicate to determine if a call expression's result is utilized
predicate isCallResultUsed(Call callExpr) {
  // Case 1: Call is nested within another expression (call/attribute/subscript)
  exists(Expr outerExpr | 
    outerExpr != callExpr and 
    outerExpr.containsInScope(callExpr) and
    (outerExpr instanceof Call or 
     outerExpr instanceof Attribute or 
     outerExpr instanceof Subscript)
  )
  // Case 2: Call is part of a statement (excluding expression statements and single returns)
  or
  exists(Stmt parentStmt |
    callExpr = parentStmt.getASubExpression() and
    not parentStmt instanceof ExprStmt and
    /* Exclude single return statements (common pattern: def f(): return g()) */
    not (parentStmt instanceof Return and 
         strictcount(Return r | r.getScope() = parentStmt.getScope()) = 1)
  )
}

// Identify problematic procedure return value usage
from Call callExpr, FunctionValue targetFunc
where
  /* Core condition: Call result is utilized */
  isCallResultUsed(callExpr) and
  
  /* Target function resolution and procedure verification */
  callExpr.getFunc().pointsTo(targetFunc) and
  targetFunc.getScope().isProcedure() and
  
  /* Ensure all possible callees are procedures */
  forall(FunctionValue possibleCallee | 
    callExpr.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  
  /* Exclude Mox test framework cases (uses AndReturn method) */
  not useOfMoxInModule(callExpr.getEnclosingModule())
select callExpr, 
       "The result of $@ is used even though it is always None.", 
       targetFunc, 
       targetFunc.getQualifiedName()