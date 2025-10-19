/**
 * @name Ignored return value
 * @description Detects when return values from functions are ignored, which may lead to discarding errors or loss of important information.
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

// Determines if an expression represents a significant return value that should not be ignored
predicate has_significant_return_value(Expr returnedExpr) {
  // Names and boolean literals are considered significant return values
  returnedExpr instanceof Name
  or
  returnedExpr instanceof BooleanLiteral
  or
  // Function call results are significant if the called function returns meaningful values
  exists(FunctionValue calledFunc |
    returnedExpr = calledFunc.getACall().getNode() and function_returns_meaningful_value(calledFunc)
  )
  or
  // Non-function-call expressions that aren't simple names are considered significant
  not exists(FunctionValue calledFunc | returnedExpr = calledFunc.getACall().getNode()) and not returnedExpr instanceof Name
}

/* A value is considered used if it is accessed multiple times in the same scope */
// Determines if a value is referenced multiple times, indicating it's being used
predicate is_value_used(Expr returnedExpr) {
  // Value is used if it's a local variable accessed multiple times
  exists(LocalVariable localVar, Expr anotherAccess |
    localVar.getAnAccess() = returnedExpr and anotherAccess = localVar.getAnAccess() and not anotherAccess = returnedExpr
  )
}

// Determines if a function returns values that should not be ignored
predicate function_returns_meaningful_value(FunctionValue calledFunc) {
  // Functions without fallthrough nodes (e.g., with exception handling) may return meaningful values
  not exists(calledFunc.getScope().getFallthroughNode()) and
  (
    // Function returns meaningful values if it has return statements with significant values that aren't used
    exists(Return retStmt, Expr retValue | 
      retStmt.getScope() = calledFunc.getScope() and 
      retValue = retStmt.getValue() and
      has_significant_return_value(retValue) and
      not is_value_used(retValue)
    )
    or
    /*
     * Check if function is a builtin that returns something other than None.
     * Exclude __import__ as it is often called purely for side effects.
     */
    // Builtin functions that don't return None (excluding __import__) are considered to return meaningful values
    calledFunc.isBuiltin() and
    calledFunc.getAnInferredReturnType() != ClassValue::nonetype() and
    not calledFunc.getName() = "__import__"
  )
}

/* Expressions wrapped tightly in try-except blocks are assumed to be executed for exception handling, not their return value */
// Determines if an expression statement is tightly wrapped in a try-except block
predicate is_tightly_wrapped_in_try_except(ExprStmt callExprStmt) {
  // Consider a call tightly wrapped if it's the only statement in a try block with exception handlers
  exists(Try tryStmt |
    exists(tryStmt.getAHandler()) and
    strictcount(Call callNode | tryStmt.getBody().contains(callNode)) = 1 and
    callExprStmt = tryStmt.getAStmt()
  )
}

from ExprStmt callExprStmt, FunctionValue calledFunc, float utilizationRate, int totalCallCount
where
  // The call is not tightly wrapped in a try-except block (which would indicate it's for exception handling)
  not is_tightly_wrapped_in_try_except(callExprStmt) and
  // Identify calls to functions that return meaningful values
  callExprStmt.getValue() = calledFunc.getACall().getNode() and
  // The called function returns values that should not be ignored
  function_returns_meaningful_value(calledFunc) and
  // Calculate the percentage of calls where the return value is used
  exists(int discardedCallCount |
    discardedCallCount = count(ExprStmt discardedCallExprStmt | discardedCallExprStmt.getValue().getAFlowNode() = calledFunc.getACall()) and
    totalCallCount = count(calledFunc.getACall()) and
    utilizationRate = (100.0 * (totalCallCount - discardedCallCount) / totalCallCount).floor()
  ) and
  /* Report an alert if we observe at least 5 calls and the return value is used in at least 75% of those calls. */
  // Trigger alert for functions with sufficient call volume where return values are typically used
  utilizationRate >= 75 and
  totalCallCount >= 5
select callExprStmt,
  "Call discards return value of function $@. The result is used in " + utilizationRate.toString() +
    "% of calls.", calledFunc, calledFunc.getName()