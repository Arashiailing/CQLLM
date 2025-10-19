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
predicate has_significant_return_value(Expr returnValue) {
  // Consider names and boolean literals as significant return values
  returnValue instanceof Name
  or
  returnValue instanceof BooleanLiteral
  or
  // Consider function call results significant if the called function returns meaningful values
  exists(FunctionValue calledFunction |
    returnValue = calledFunction.getACall().getNode() and function_returns_meaningful_value(calledFunction)
  )
  or
  // Consider non-function-call expressions that aren't simple names as significant
  not exists(FunctionValue calledFunction | returnValue = calledFunction.getACall().getNode()) and not returnValue instanceof Name
}

/* A value is considered used if it is accessed multiple times in the same scope */
// Determines if a value is referenced multiple times, indicating it's being used
predicate is_value_used(Expr returnValue) {
  // Value is used if it's a local variable accessed multiple times
  exists(LocalVariable localVar, Expr otherAccess |
    localVar.getAnAccess() = returnValue and otherAccess = localVar.getAnAccess() and not otherAccess = returnValue
  )
}

// Determines if a function returns values that should not be ignored
predicate function_returns_meaningful_value(FunctionValue func) {
  // Functions without fallthrough nodes (e.g., with exception handling) may return meaningful values
  not exists(func.getScope().getFallthroughNode()) and
  (
    // Function is considered to return meaningful values if it has return statements with significant values that aren't used
    exists(Return returnStmt, Expr returnValue | returnStmt.getScope() = func.getScope() and returnValue = returnStmt.getValue() |
      has_significant_return_value(returnValue) and
      not is_value_used(returnValue)
    )
    or
    /*
     * Check if func is a builtin function that returns something other than None.
     * Exclude __import__ as it is often called purely for side effects.
     */
    // Builtin functions that don't return None (excluding __import__) are considered to return meaningful values
    func.isBuiltin() and
    func.getAnInferredReturnType() != ClassValue::nonetype() and
    not func.getName() = "__import__"
  )
}

/* Expressions wrapped tightly in try-except blocks are assumed to be executed for exception handling, not their return value */
// Determines if an expression statement is tightly wrapped in a try-except block
predicate is_tightly_wrapped_in_try_except(ExprStmt callStmt) {
  // Consider a call tightly wrapped if it's the only statement in a try block with exception handlers
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call c | tryBlock.getBody().contains(c)) = 1 and
    callStmt = tryBlock.getAStmt()
  )
}

from ExprStmt callStmt, FunctionValue calledFunction, float usagePercentage, int totalCalls
where
  // Identify calls to functions that return meaningful values
  callStmt.getValue() = calledFunction.getACall().getNode() and
  // The called function returns values that should not be ignored
  function_returns_meaningful_value(calledFunction) and
  // The call is not tightly wrapped in a try-except block (which would indicate it's for exception handling)
  not is_tightly_wrapped_in_try_except(callStmt) and
  // Calculate the percentage of calls where the return value is used
  exists(int unusedCalls |
    unusedCalls = count(ExprStmt e | e.getValue().getAFlowNode() = calledFunction.getACall()) and
    totalCalls = count(calledFunction.getACall())
  |
    usagePercentage = (100.0 * (totalCalls - unusedCalls) / totalCalls).floor()
  ) and
  /* Report an alert if we observe at least 5 calls and the return value is used in at least 75% of those calls. */
  // Trigger alert for functions with sufficient call volume where return values are typically used
  usagePercentage >= 75 and
  totalCalls >= 5
select callStmt,
  "Call discards return value of function $@. The result is used in " + usagePercentage.toString() +
    "% of calls.", calledFunction, calledFunction.getName()