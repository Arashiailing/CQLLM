/**
 * @name Use of the return value of a procedure
 * @description Finds code that uses the return value of a procedure (a function that returns None). 
 *              This is confusing because the return value (None) has no meaningful use.
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
 * Determines if a call expression's result is used in the code.
 * A call result is considered used if:
 *   (1) It is part of a larger expression (e.g., as an argument to another call, attribute access, or subscript)
 *   (2) It is used in a statement that is not an expression statement (excluding single return statements)
 */
predicate isCallResultUsed(Call callNode) {
  // Case 1: Call is embedded in a larger expression
  exists(Expr enclosingNode | 
    enclosingNode != callNode and 
    enclosingNode.containsInScope(callNode) and
    (enclosingNode instanceof Call or 
     enclosingNode instanceof Attribute or 
     enclosingNode instanceof Subscript)
  )
  // Case 2: Call is used in a non-expression statement (excluding single returns)
  or
  exists(Stmt parentStatement |
    callNode = parentStatement.getASubExpression() and
    not parentStatement instanceof ExprStmt and
    // Skip single return statements (common pattern)
    not (parentStatement instanceof Return and 
         strictcount(Return r | r.getScope() = parentStatement.getScope()) = 1)
  )
}

// Find calls to procedures where the return value is used
from Call procCall, FunctionValue targetFunction
where
  // The call result is used in code
  isCallResultUsed(procCall) and
  // Identify the called function
  procCall.getFunc().pointsTo(targetFunction) and
  // Verify the function is a procedure (returns None)
  targetFunction.getScope().isProcedure() and
  // Ensure all possible callees (due to polymorphism) are procedures
  forall(FunctionValue possibleCallee | 
    procCall.getFunc().pointsTo(possibleCallee) | 
    possibleCallee.getScope().isProcedure()
  ) and
  // Exclude modules using Mox framework
  not useOfMoxInModule(procCall.getEnclosingModule())
select procCall, 
       "The result of $@ is used even though it is always None.", 
       targetFunction, 
       targetFunction.getQualifiedName()