/**
 * @name Use of the return value of a procedure
 * @description Detects when the return value of a procedure (a function that does not return a value) is used. 
 *              This is confusing to the reader as the value (None) has no meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines if a call expression's result is used in the code
predicate isCallResultUsed(Call callExpr) {
  // Case 1: The call is part of a larger expression
  exists(Expr enclosingExpr | 
    enclosingExpr != callExpr and 
    enclosingExpr.containsInScope(callExpr) and
    (enclosingExpr instanceof Call or 
     enclosingExpr instanceof Attribute or 
     enclosingExpr instanceof Subscript)
  )
  // Case 2: The call is used in a statement that's not an expression statement
  or
  exists(Stmt parentStmt |
    callExpr = parentStmt.getASubExpression() and
    not parentStmt instanceof ExprStmt and
    // Exclude single return statements as they're common patterns
    not (parentStmt instanceof Return and 
         strictcount(Return r | r.getScope() = parentStmt.getScope()) = 1)
  )
}

// Find calls to procedures where the return value is used
from Call procedureCall, FunctionValue calledFunction
where
  isCallResultUsed(procedureCall) and
  procedureCall.getFunc().pointsTo(calledFunction) and
  calledFunction.getScope().isProcedure() and
  // All possible callees are procedures (handle polymorphism)
  forall(FunctionValue possibleCallee | 
    procedureCall.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  // Exclude cases where Mox is used in the module
  not useOfMoxInModule(procedureCall.getEnclosingModule())
select procedureCall, 
       "The result of $@ is used even though it is always None.", 
       calledFunction, 
       calledFunction.getQualifiedName()