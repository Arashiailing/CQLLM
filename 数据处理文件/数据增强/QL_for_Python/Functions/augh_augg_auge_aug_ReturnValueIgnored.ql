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

// Evaluates whether an expression represents a significant return value that should not be ignored
predicate has_significant_return_value(Expr significantExpr) {
  // Names and boolean literals are considered significant return values
  significantExpr instanceof Name
  or
  significantExpr instanceof BooleanLiteral
  or
  // Function call results are significant if the called function returns meaningful values
  exists(FunctionValue calleeFunc |
    significantExpr = calleeFunc.getACall().getNode() and function_returns_meaningful_value(calleeFunc)
  )
  or
  // Non-function-call expressions that aren't simple names are considered significant
  not exists(FunctionValue calleeFunc | significantExpr = calleeFunc.getACall().getNode()) and not significantExpr instanceof Name
}

/* A value is considered used if it is accessed multiple times in the same scope */
// Determines if a value is referenced multiple times, indicating it's being used
predicate is_value_used(Expr significantExpr) {
  // Value is used if it's a local variable accessed multiple times
  exists(LocalVariable localVariable, Expr otherAccess |
    localVariable.getAnAccess() = significantExpr and otherAccess = localVariable.getAnAccess() and not otherAccess = significantExpr
  )
}

// Evaluates if a function returns values that should not be ignored
predicate function_returns_meaningful_value(FunctionValue calleeFunc) {
  // Functions without fallthrough nodes (e.g., with exception handling) may return meaningful values
  not exists(calleeFunc.getScope().getFallthroughNode()) and
  (
    // Function returns meaningful values if it has return statements with significant values that aren't used
    exists(Return returnStmt, Expr returnValue | 
      returnStmt.getScope() = calleeFunc.getScope() and 
      returnValue = returnStmt.getValue() and
      has_significant_return_value(returnValue) and
      not is_value_used(returnValue)
    )
    or
    /*
     * Check if function is a builtin that returns something other than None.
     * Exclude __import__ as it is often called purely for side effects.
     */
    // Builtin functions that don't return None (excluding __import__) are considered to return meaningful values
    calleeFunc.isBuiltin() and
    calleeFunc.getAnInferredReturnType() != ClassValue::nonetype() and
    not calleeFunc.getName() = "__import__"
  )
}

/* Expressions wrapped tightly in try-except blocks are assumed to be executed for exception handling, not their return value */
// Determines if an expression statement is tightly wrapped in a try-except block
predicate is_tightly_wrapped_in_try_except(ExprStmt callStatement) {
  // Consider a call tightly wrapped if it's the only statement in a try block with exception handlers
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call callInTry | tryBlock.getBody().contains(callInTry)) = 1 and
    callStatement = tryBlock.getAStmt()
  )
}

from ExprStmt callStatement, FunctionValue calleeFunc, float usagePercentage, int totalCalls
where
  // The call is not tightly wrapped in a try-except block (which would indicate it's for exception handling)
  not is_tightly_wrapped_in_try_except(callStatement) and
  // Identify calls to functions that return meaningful values
  callStatement.getValue() = calleeFunc.getACall().getNode() and
  // The called function returns values that should not be ignored
  function_returns_meaningful_value(calleeFunc) and
  // Calculate the percentage of calls where the return value is used
  exists(int ignoredCallCount |
    ignoredCallCount = count(ExprStmt ignoredCallStatement | ignoredCallStatement.getValue().getAFlowNode() = calleeFunc.getACall()) and
    totalCalls = count(calleeFunc.getACall()) and
    usagePercentage = (100.0 * (totalCalls - ignoredCallCount) / totalCalls).floor()
  ) and
  /* Report an alert if we observe at least 5 calls and the return value is used in at least 75% of those calls. */
  // Trigger alert for functions with sufficient call volume where return values are typically used
  usagePercentage >= 75 and
  totalCalls >= 5
select callStatement,
  "Call discards return value of function $@. The result is used in " + usagePercentage.toString() +
    "% of calls.", calleeFunc, calleeFunc.getName()