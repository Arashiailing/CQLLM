/**
 * @name Use of the return value of a procedure
 * @description Identifies usage of return values from procedures (functions that don't return meaningful values). 
 *              This is misleading since the value (None) has no semantic meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines if a call's return value is utilized in the code
predicate isCallResultUsed(Call invocation) {
  // Case 1: Call is embedded within a value-requiring expression
  exists(Expr containerExpr | 
    containerExpr != invocation and 
    containerExpr.containsInScope(invocation) and
    (containerExpr instanceof Call or 
     containerExpr instanceof Attribute or 
     containerExpr instanceof Subscript)
  )
  // Case 2: Call appears in a statement that expects a value (not standalone expression)
  or
  exists(Stmt parentStmt |
    invocation = parentStmt.getASubExpression() and
    not parentStmt instanceof ExprStmt and
    // Exclude single return statements as they're conventional patterns
    not (parentStmt instanceof Return and 
         strictcount(Return r | r.getScope() = parentStmt.getScope()) = 1)
  )
}

// Identify procedure calls where return values are improperly utilized
from Call procedureCall, FunctionValue targetFunction
where
  isCallResultUsed(procedureCall) and
  procedureCall.getFunc().pointsTo(targetFunction) and
  targetFunction.getScope().isProcedure() and
  // Ensure all potential callees are procedures (handles polymorphic cases)
  forall(FunctionValue possibleCallee | 
    procedureCall.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  // Exclude modules utilizing Mox testing framework
  not useOfMoxInModule(procedureCall.getEnclosingModule())
select procedureCall, 
       "The result of $@ is used even though it is always None.", 
       targetFunction, 
       targetFunction.getQualifiedName()