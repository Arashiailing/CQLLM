/**
 * @name Procedure return value utilization
 * @description Identifies usage of return values from procedures (functions without meaningful return values). 
 *              This is problematic since the returned value (None) carries no semantic meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines if a function call's result is utilized in the code
predicate isCallResultUsed(Call functionCall) {
  // Case 1: Call is nested within a value-requiring expression
  exists(Expr containerExpr | 
    containerExpr != functionCall and 
    containerExpr.containsInScope(functionCall) and
    (containerExpr instanceof Call or 
     containerExpr instanceof Attribute or 
     containerExpr instanceof Subscript)
  )
  // Case 2: Call appears in a value-expecting statement (not standalone)
  or
  exists(Stmt parentStmt |
    functionCall = parentStmt.getASubExpression() and
    not parentStmt instanceof ExprStmt and
    // Exclude conventional single-return patterns
    not (parentStmt instanceof Return and 
         strictcount(Return r | r.getScope() = parentStmt.getScope()) = 1)
  )
}

// Identify procedure calls with improperly utilized return values
from Call invocation, FunctionValue targetFunction
where
  // Verify return value usage
  isCallResultUsed(invocation) and
  // Confirm call targets a specific function
  invocation.getFunc().pointsTo(targetFunction) and
  // Validate target function is a procedure
  targetFunction.getScope().isProcedure() and
  // Ensure all potential callees are procedures (handles polymorphism)
  forall(FunctionValue potentialCallee | 
    invocation.getFunc().pointsTo(potentialCallee) | 
    potentialCallee.getScope().isProcedure()
  ) and
  // Exclude modules using Mox testing framework
  not useOfMoxInModule(invocation.getEnclosingModule())
select invocation, 
       "The result of $@ is used even though it is always None.", 
       targetFunction, 
       targetFunction.getQualifiedName()