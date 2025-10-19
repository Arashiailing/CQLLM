/**
 * @name Use of the return value of a procedure
 * @description Identifies usage of return values from procedures (functions that return None).
 *              Such usage is misleading since the value (None) carries no meaningful information.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines if a call's result is utilized in the code
predicate isCallResultUsed(Call callNode) {
  // Case 1: Call is embedded within a larger expression
  exists(Expr enclosingExpression | 
    enclosingExpression != callNode and 
    enclosingExpression.containsInScope(callNode) and
    (enclosingExpression instanceof Call or 
     enclosingExpression instanceof Attribute or 
     enclosingExpression instanceof Subscript)
  )
  // Case 2: Call appears in a non-expression statement
  or
  exists(Stmt parentStatement |
    callNode = parentStatement.getASubExpression() and
    not parentStatement instanceof ExprStmt and
    // Exclude standalone return statements (common pattern)
    not (parentStatement instanceof Return and 
         strictcount(Return ret | ret.getScope() = parentStatement.getScope()) = 1)
  )
}

// Find procedure calls where return value is utilized
from Call procedureCall, FunctionValue calledFunction
where
  // Verify return value is actually used
  isCallResultUsed(procedureCall) and
  
  // Resolve called function and verify it's a procedure
  procedureCall.getFunc().pointsTo(calledFunction) and
  calledFunction.getScope().isProcedure() and
  
  // Ensure all possible callees are procedures (handles polymorphism)
  forall(FunctionValue possibleCallee | 
    procedureCall.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  
  // Exclude modules using Mox framework
  not useOfMoxInModule(procedureCall.getEnclosingModule())
select procedureCall, 
       "The result of $@ is used even though it is always None.", 
       calledFunction, 
       calledFunction.getQualifiedName()