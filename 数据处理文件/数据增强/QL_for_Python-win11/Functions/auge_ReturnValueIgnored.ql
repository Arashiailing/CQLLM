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

// Determines if the return value has practical significance
predicate meaningful_return_value(Expr returnValue) {
  // Consider identifiers and boolean literals as significant
  returnValue instanceof Name
  or
  returnValue instanceof BooleanLiteral
  or
  // Consider function call results significant when the function returns meaningful values
  exists(FunctionValue calledFunction |
    returnValue = calledFunction.getACall().getNode() and returns_meaningful_value(calledFunction)
  )
  or
  // Consider non-call, non-identifier expressions as significant
  not exists(FunctionValue calledFunction | returnValue = calledFunction.getACall().getNode()) and 
  not returnValue instanceof Name
}

/* Value is accessed elsewhere before returning, indicating its value isn't lost if ignored */
// Checks if the value is utilized before being returned
predicate used_value(Expr returnValue) {
  // Value is used if a local variable is accessed elsewhere
  exists(LocalVariable localVar, Expr otherAccess |
    localVar.getAnAccess() = returnValue and 
    otherAccess = localVar.getAnAccess() and 
    not otherAccess = returnValue
  )
}

// Evaluates whether the function returns a value of significance
predicate returns_meaningful_value(FunctionValue func) {
  // Functions without fallthrough nodes (e.g., with exception handling)
  not exists(func.getScope().getFallthroughNode()) and
  (
    // Functions with return statements containing meaningful, unused values
    exists(Return returnStmt, Expr returnedValue | 
      returnStmt.getScope() = func.getScope() and 
      returnedValue = returnStmt.getValue() |
      meaningful_return_value(returnedValue) and
      not used_value(returnedValue)
    )
    or
    /*
     * Is func a builtin function that returns something other than None?
     * Exclude __import__ as it's often called purely for side effects
     */
    // Builtin functions with non-None return types (excluding __import__)
    func.isBuiltin() and
    func.getAnInferredReturnType() != ClassValue::nonetype() and
    not func.getName() = "__import__"
  )
}

/* If a call is tightly wrapped in a try-except block, assume it's executed for exception handling */
// Determines if the expression statement is tightly enclosed in a try-except block
predicate wrapped_in_try_except(ExprStmt stmt) {
  // Single-statement try block with exception handlers
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call callInTry | tryBlock.getBody().contains(callInTry)) = 1 and
    stmt = tryBlock.getAStmt()
  )
}

from ExprStmt callStmt, FunctionValue calledFunc, float usagePercentage, int totalCalls
where
  // Identify call statements and their target functions
  callStmt.getValue() = calledFunc.getACall().getNode() and
  // Target function returns meaningful values
  returns_meaningful_value(calledFunc) and
  // Call is not tightly wrapped in try-except
  not wrapped_in_try_except(callStmt) and
  // Calculate usage statistics
  exists(int unusedCount |
    unusedCount = count(ExprStmt stmt | stmt.getValue().getAFlowNode() = calledFunc.getACall()) and
    totalCalls = count(calledFunc.getACall())
  |
    usagePercentage = (100.0 * (totalCalls - unusedCount) / totalCalls).floor()
  ) and
  /* Report when at least 5 calls exist and return value is used in 75%+ of cases */
  usagePercentage >= 75 and
  totalCalls >= 5
select callStmt,
  "Call discards return value of function $@. The result is used in " + usagePercentage.toString() +
    "% of calls.", calledFunc, calledFunc.getName()