/**
 * @name Procedure Return Value Usage
 * @description Identifies instances where the return value of a procedure (a function designed not to return a meaningful value) 
 *              is utilized in the code. This practice can be misleading since the returned value (None) carries no significance.
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
predicate isProcedureCallResultUtilized(Call procedureInvocation) {
  // Case 1: The call is part of a larger expression
  exists(Expr containerExpression | 
    containerExpression != procedureInvocation and 
    containerExpression.containsInScope(procedureInvocation) and
    (containerExpression instanceof Call or 
     containerExpression instanceof Attribute or 
     containerExpression instanceof Subscript)
  )
  // Case 2: The call is used in a statement that's not an expression statement
  or
  exists(Stmt ancestorStatement |
    procedureInvocation = ancestorStatement.getASubExpression() and
    not ancestorStatement instanceof ExprStmt and
    // Exclude single return statements as they're common patterns
    not (ancestorStatement instanceof Return and 
         strictcount(Return r | r.getScope() = ancestorStatement.getScope()) = 1)
  )
}

// Find calls to procedures where the return value is used
from Call targetProcedureCall, FunctionValue invokedProcedure
where
  isProcedureCallResultUtilized(targetProcedureCall) and
  targetProcedureCall.getFunc().pointsTo(invokedProcedure) and
  invokedProcedure.getScope().isProcedure() and
  // All possible callees are procedures (handle polymorphism)
  forall(FunctionValue potentialTargetFunction | 
    targetProcedureCall.getFunc().pointsTo(potentialTargetFunction) | 
    potentialTargetFunction.getScope().isProcedure()
  ) and
  // Exclude cases where Mox is used in the module
  not useOfMoxInModule(targetProcedureCall.getEnclosingModule())
select targetProcedureCall, 
       "The result of $@ is used even though it is always None.", 
       invokedProcedure, 
       invokedProcedure.getQualifiedName()