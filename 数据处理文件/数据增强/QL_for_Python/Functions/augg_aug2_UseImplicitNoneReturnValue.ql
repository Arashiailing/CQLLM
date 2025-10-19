/**
 * @name Use of the return value of a procedure
 * @description Identifies instances where the return value of a procedure (a function that does not return a value) is utilized. 
 *              This practice is confusing since the value (None) carries no meaningful information.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines whether a function call's result is utilized in the code
predicate isCallResultUsed(Call invocation) {
  // Scenario 1: The call is embedded within a larger expression
  exists(Expr containerExpr | 
    containerExpr != invocation and 
    containerExpr.containsInScope(invocation) and
    (containerExpr instanceof Call or 
     containerExpr instanceof Attribute or 
     containerExpr instanceof Subscript)
  )
  // Scenario 2: The call appears in a non-expression statement
  or
  exists(Stmt parentStatement |
    invocation = parentStatement.getASubExpression() and
    not parentStatement instanceof ExprStmt and
    // Exclude isolated return statements as they represent common patterns
    not (parentStatement instanceof Return and 
         strictcount(Return r | r.getScope() = parentStatement.getScope()) = 1)
  )
}

// Identify calls to procedures where the return value is utilized
from Call procedureCall, FunctionValue targetFunction
where
  isCallResultUsed(procedureCall) and
  procedureCall.getFunc().pointsTo(targetFunction) and
  targetFunction.getScope().isProcedure() and
  // Ensure all potential callees are procedures (handling polymorphism)
  forall(FunctionValue possibleCallee | 
    procedureCall.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  // Exclude modules utilizing Mox framework
  not useOfMoxInModule(procedureCall.getEnclosingModule())
select procedureCall, 
       "The result of $@ is used even though it is always None.", 
       targetFunction, 
       targetFunction.getQualifiedName()