/**
 * @name Use of the return value of a procedure
 * @description Detects when return values from procedures (functions that don't return meaningful values) 
 *              are utilized in the code. This is problematic since the returned value (None) 
 *              carries no semantic meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines whether a function call's return value is utilized in the code
predicate isCallResultUsed(Call funcCall) {
  // Case 1: Call is nested within an expression requiring a value
  exists(Expr enclosingExpr | 
    enclosingExpr != funcCall and 
    enclosingExpr.containsInScope(funcCall) and
    (enclosingExpr instanceof Call or 
     enclosingExpr instanceof Attribute or 
     enclosingExpr instanceof Subscript)
  )
  // Case 2: Call appears in a statement expecting a value (not standalone)
  or
  exists(Stmt parentStatement |
    funcCall = parentStatement.getASubExpression() and
    not parentStatement instanceof ExprStmt and
    // Exclude single return statements as conventional patterns
    not (parentStatement instanceof Return and 
         strictcount(Return r | r.getScope() = parentStatement.getScope()) = 1)
  )
}

// Identify procedure calls where return values are improperly utilized
from Call funcInvocation, FunctionValue calledFunction
where
  // Check if return value is used
  isCallResultUsed(funcInvocation) and
  // Verify call targets a specific function
  funcInvocation.getFunc().pointsTo(calledFunction) and
  // Confirm target function is a procedure
  calledFunction.getScope().isProcedure() and
  // Ensure all potential callees are procedures (handles polymorphism)
  forall(FunctionValue possibleCallee | 
    funcInvocation.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  // Exclude modules using Mox testing framework
  not useOfMoxInModule(funcInvocation.getEnclosingModule())
select funcInvocation, 
       "The result of $@ is used even though it is always None.", 
       calledFunction, 
       calledFunction.getQualifiedName()