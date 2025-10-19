/**
 * @name Unused Return Value
 * @description Disregarding return values can lead to ignoring errors or losing important information.
 * @kind problem
 * @tags reliability
 *       readability
 *       convention
 *       statistical
 *       non-attributable
 *       external/cwe/cwe-252
 * @problem.severity recommendation
 * @sub-severity high
 * @precision medium
 * @id py/ignored-return-value
 */

import python
import semmle.python.objects.Callables

// Determines if an expression represents a significant return value
predicate is_significant_return(Expr returnedExpr) {
  // Identifiers and boolean literals are considered significant
  returnedExpr instanceof Name
  or
  returnedExpr instanceof BooleanLiteral
  or
  // Function call results are significant when the function returns meaningful values
  exists(FunctionValue calledFunction |
    returnedExpr = calledFunction.getACall().getNode() and 
    function_returns_meaningful_value(calledFunction)
  )
  or
  // Non-call, non-identifier expressions are considered significant
  not exists(FunctionValue calledFunction | returnedExpr = calledFunction.getACall().getNode()) and 
  not returnedExpr instanceof Name
}

/* Value is accessed elsewhere before returning, indicating its value isn't lost if ignored */
// Checks if a returned value is utilized elsewhere in the code
predicate is_value_utilized(Expr returnedExpr) {
  // Value is used if a local variable is accessed in multiple locations
  exists(LocalVariable localVar, Expr otherUsage |
    localVar.getAnAccess() = returnedExpr and 
    otherUsage = localVar.getAnAccess() and 
    not otherUsage = returnedExpr
  )
}

// Evaluates whether a function returns values of practical significance
predicate function_returns_meaningful_value(FunctionValue calledFunction) {
  // Functions without fallthrough nodes (e.g., with exception handling)
  not exists(calledFunction.getScope().getFallthroughNode()) and
  (
    // Functions with return statements containing meaningful, unused values
    exists(Return retStmt, Expr returnValue | 
      retStmt.getScope() = calledFunction.getScope() and 
      returnValue = retStmt.getValue() |
      is_significant_return(returnValue) and
      not is_value_utilized(returnValue)
    )
    or
    /*
     * Is calledFunction a builtin function that returns something other than None?
     * Exclude __import__ as it's often called purely for side effects
     */
    // Builtin functions with non-None return types (excluding __import__)
    calledFunction.isBuiltin() and
    calledFunction.getAnInferredReturnType() != ClassValue::nonetype() and
    not calledFunction.getName() = "__import__"
  )
}

/* If a call is tightly wrapped in a try-except block, assume it's executed for exception handling */
// Determines if an expression statement is tightly enclosed in a try-except block
predicate is_wrapped_in_try_except(ExprStmt exprStatement) {
  // Single-statement try block with exception handlers
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call callInTry | tryBlock.getBody().contains(callInTry)) = 1 and
    exprStatement = tryBlock.getAStmt()
  )
}

from ExprStmt exprStatement, FunctionValue calledFunction, float usagePercentage, int totalCalls
where
  // Identify call statements and their target functions
  exprStatement.getValue() = calledFunction.getACall().getNode() and
  // Target function returns meaningful values
  function_returns_meaningful_value(calledFunction) and
  // Call is not tightly wrapped in try-except
  not is_wrapped_in_try_except(exprStatement) and
  // Calculate usage statistics
  totalCalls = count(calledFunction.getACall()) and
  exists(int unusedCalls |
    unusedCalls = count(ExprStmt stmt | stmt.getValue().getAFlowNode() = calledFunction.getACall()) and
    usagePercentage = (100.0 * (totalCalls - unusedCalls) / totalCalls).floor()
  ) and
  /* Report when at least 5 calls exist and return value is used in 75%+ of cases */
  usagePercentage >= 75 and
  totalCalls >= 5
select exprStatement,
  "Call discards return value of function $@. The result is used in " + usagePercentage.toString() +
    "% of calls.", calledFunction, calledFunction.getName()