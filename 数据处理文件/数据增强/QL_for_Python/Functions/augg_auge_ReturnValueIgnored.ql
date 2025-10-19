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
predicate significant_return_value(Expr retVal) {
  // Identifiers and boolean literals are considered significant
  retVal instanceof Name
  or
  retVal instanceof BooleanLiteral
  or
  // Function call results are significant when the function returns meaningful values
  exists(FunctionValue calleeFunc |
    retVal = calleeFunc.getACall().getNode() and 
    returns_meaningful_value(calleeFunc)
  )
  or
  // Non-call, non-identifier expressions are considered significant
  not exists(FunctionValue calleeFunc | retVal = calleeFunc.getACall().getNode()) and 
  not retVal instanceof Name
}

/* Value is accessed elsewhere before returning, indicating its value isn't lost if ignored */
// Checks if a returned value is utilized elsewhere in the code
predicate utilized_value(Expr retVal) {
  // Value is used if a local variable is accessed in multiple locations
  exists(LocalVariable localVar, Expr otherAccess |
    localVar.getAnAccess() = retVal and 
    otherAccess = localVar.getAnAccess() and 
    not otherAccess = retVal
  )
}

// Evaluates whether a function returns values of practical significance
predicate returns_meaningful_value(FunctionValue calleeFunc) {
  // Functions without fallthrough nodes (e.g., with exception handling)
  not exists(calleeFunc.getScope().getFallthroughNode()) and
  (
    // Functions with return statements containing meaningful, unused values
    exists(Return retStmt, Expr returnedValue | 
      retStmt.getScope() = calleeFunc.getScope() and 
      returnedValue = retStmt.getValue() |
      significant_return_value(returnedValue) and
      not utilized_value(returnedValue)
    )
    or
    /*
     * Is calleeFunc a builtin function that returns something other than None?
     * Exclude __import__ as it's often called purely for side effects
     */
    // Builtin functions with non-None return types (excluding __import__)
    calleeFunc.isBuiltin() and
    calleeFunc.getAnInferredReturnType() != ClassValue::nonetype() and
    not calleeFunc.getName() = "__import__"
  )
}

/* If a call is tightly wrapped in a try-except block, assume it's executed for exception handling */
// Determines if an expression statement is tightly enclosed in a try-except block
predicate enclosed_in_try_except(ExprStmt exprStmt) {
  // Single-statement try block with exception handlers
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call callInTry | tryBlock.getBody().contains(callInTry)) = 1 and
    exprStmt = tryBlock.getAStmt()
  )
}

from ExprStmt exprStmt, FunctionValue calleeFunc, float usageRate, int totalCallCount
where
  // Identify call statements and their target functions
  exprStmt.getValue() = calleeFunc.getACall().getNode() and
  // Target function returns meaningful values
  returns_meaningful_value(calleeFunc) and
  // Call is not tightly wrapped in try-except
  not enclosed_in_try_except(exprStmt) and
  // Calculate usage statistics
  totalCallCount = count(calleeFunc.getACall()) and
  exists(int unusedCallCount |
    unusedCallCount = count(ExprStmt stmt | stmt.getValue().getAFlowNode() = calleeFunc.getACall()) and
    usageRate = (100.0 * (totalCallCount - unusedCallCount) / totalCallCount).floor()
  ) and
  /* Report when at least 5 calls exist and return value is used in 75%+ of cases */
  usageRate >= 75 and
  totalCallCount >= 5
select exprStmt,
  "Call discards return value of function $@. The result is used in " + usageRate.toString() +
    "% of calls.", calleeFunc, calleeFunc.getName()