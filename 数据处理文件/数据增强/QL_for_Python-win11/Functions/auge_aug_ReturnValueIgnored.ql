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

// Determines if a return value carries significant information that should not be ignored
predicate has_significant_return_value(Expr resultValue) {
  // Consider names and boolean literals as significant return values
  resultValue instanceof Name
  or
  resultValue instanceof BooleanLiteral
  or
  // Consider function call results significant if the called function returns meaningful values
  exists(FunctionValue funcValue |
    resultValue = funcValue.getACall().getNode() and function_returns_meaningful_value(funcValue)
  )
  or
  // Consider non-function-call expressions that aren't simple names as significant
  not exists(FunctionValue funcValue | resultValue = funcValue.getACall().getNode()) and not resultValue instanceof Name
}

/* A value is considered used if it is accessed multiple times in the same scope */
// Determines if a value is referenced multiple times, indicating it's being used
predicate is_value_used(Expr resultValue) {
  // Value is used if it's a local variable accessed multiple times
  exists(LocalVariable localVar, Expr otherAccess |
    localVar.getAnAccess() = resultValue and otherAccess = localVar.getAnAccess() and not otherAccess = resultValue
  )
}

// Determines if a function returns values that should not be ignored
predicate function_returns_meaningful_value(FunctionValue funcValue) {
  // Functions without fallthrough nodes (e.g., with exception handling) may return meaningful values
  not exists(funcValue.getScope().getFallthroughNode()) and
  (
    // Function is considered to return meaningful values if it has return statements with significant values that aren't used
    exists(Return returnStmt, Expr returnValue | 
      returnStmt.getScope() = funcValue.getScope() and 
      returnValue = returnStmt.getValue() and
      has_significant_return_value(returnValue) and
      not is_value_used(returnValue)
    )
    or
    /*
     * Check if func is a builtin function that returns something other than None.
     * Exclude __import__ as it is often called purely for side effects.
     */
    // Builtin functions that don't return None (excluding __import__) are considered to return meaningful values
    funcValue.isBuiltin() and
    funcValue.getAnInferredReturnType() != ClassValue::nonetype() and
    not funcValue.getName() = "__import__"
  )
}

/* Expressions wrapped tightly in try-except blocks are assumed to be executed for exception handling, not their return value */
// Determines if an expression statement is tightly wrapped in a try-except block
predicate is_tightly_wrapped_in_try_except(ExprStmt exprStmt) {
  // Consider a call tightly wrapped if it's the only statement in a try block with exception handlers
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call c | tryBlock.getBody().contains(c)) = 1 and
    exprStmt = tryBlock.getAStmt()
  )
}

from ExprStmt exprStmt, FunctionValue funcValue, float usageRate, int callCount
where
  // Identify calls to functions that return meaningful values
  exprStmt.getValue() = funcValue.getACall().getNode() and
  // The called function returns values that should not be ignored
  function_returns_meaningful_value(funcValue) and
  // The call is not tightly wrapped in a try-except block (which would indicate it's for exception handling)
  not is_tightly_wrapped_in_try_except(exprStmt) and
  // Calculate the percentage of calls where the return value is used
  exists(int ignoredCalls |
    ignoredCalls = count(ExprStmt e | e.getValue().getAFlowNode() = funcValue.getACall()) and
    callCount = count(funcValue.getACall()) and
    usageRate = (100.0 * (callCount - ignoredCalls) / callCount).floor()
  ) and
  /* Report an alert if we observe at least 5 calls and the return value is used in at least 75% of those calls. */
  // Trigger alert for functions with sufficient call volume where return values are typically used
  usageRate >= 75 and
  callCount >= 5
select exprStmt,
  "Call discards return value of function $@. The result is used in " + usageRate.toString() +
    "% of calls.", funcValue, funcValue.getName()