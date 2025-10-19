/**
 * @name Procedure return value utilization
 * @description Detects improper usage of return values from procedures (functions that always return None). 
 *              Such usage is problematic since the returned value carries no meaningful information.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Check whether the result of a function call is used in the code
predicate isCallResultUsed(Call funcCall) {
  // Scenario 1: Call is embedded within an expression requiring a value
  exists(Expr parentExpr | 
    parentExpr != funcCall and 
    parentExpr.containsInScope(funcCall) and
    (parentExpr instanceof Call or 
     parentExpr instanceof Attribute or 
     parentExpr instanceof Subscript)
  )
  // Scenario 2: Call appears in a statement expecting a value (not standalone)
  or
  exists(Stmt enclosingStmt |
    funcCall = enclosingStmt.getASubExpression() and
    not enclosingStmt instanceof ExprStmt and
    // Exclude conventional single-return patterns
    not (enclosingStmt instanceof Return and 
         strictcount(Return r | r.getScope() = enclosingStmt.getScope()) = 1)
  )
}

// Identify procedure calls with improperly utilized return values
from Call procCall, FunctionValue calledProcedure
where
  // Verify return value is being used
  isCallResultUsed(procCall) and
  // Ensure all potential targets are procedures (handles polymorphism)
  forall(FunctionValue alternativeTarget | 
    procCall.getFunc().pointsTo(alternativeTarget) | 
    alternativeTarget.getScope().isProcedure()
  ) and
  // Establish relationship to a specific procedure
  procCall.getFunc().pointsTo(calledProcedure) and
  // Exclude modules using Mox testing framework
  not useOfMoxInModule(procCall.getEnclosingModule())
select procCall, 
       "The result of $@ is used even though it is always None.", 
       calledProcedure, 
       calledProcedure.getQualifiedName()