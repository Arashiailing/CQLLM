/**
 * @name Ignored return value
 * @description Detects ignored return values that may lead to discarded errors or lost information
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

// Determines if an expression represents a meaningful return value
predicate is_meaningful_return(Expr returnExpr) {
  // Names and boolean literals are considered meaningful
  returnExpr instanceof Name
  or
  returnExpr instanceof BooleanLiteral
  or
  // Function calls that return meaningful values are also considered meaningful
  exists(FunctionValue calledFunc |
    returnExpr = calledFunc.getACall().getNode() and 
    func_returns_meaningful_value(calledFunc)
  )
  or
  // Non-call expressions that aren't simple names are considered meaningful
  not exists(FunctionValue calledFunc | 
    returnExpr = calledFunc.getACall().getNode()
  ) and 
  not returnExpr instanceof Name
}

// Determines if a returned value is actually used elsewhere in the code
predicate is_value_used_elsewhere(Expr returnExpr) {
  // Value is considered used if accessed through a local variable in other locations
  exists(LocalVariable localVar, Expr otherAccess |
    localVar.getAnAccess() = returnExpr and 
    otherAccess = localVar.getAnAccess() and 
    not otherAccess = returnExpr
  )
}

// Determines if a function returns meaningful values
predicate func_returns_meaningful_value(FunctionValue func) {
  // Functions without fallthrough nodes (e.g., with exception handling)
  not exists(func.getScope().getFallthroughNode()) and
  (
    // Functions with meaningful return statements that aren't used elsewhere
    exists(Return returnStmt, Expr returnExpr | 
      returnStmt.getScope() = func.getScope() and 
      returnExpr = returnStmt.getValue()
    |
      is_meaningful_return(returnExpr) and
      not is_value_used_elsewhere(returnExpr)
    )
    or
    /*
     * Built-in functions returning non-None values (excluding __import__)
     * which is often called for side effects only
     */
    func.isBuiltin() and
    func.getAnInferredReturnType() != ClassValue::nonetype() and
    not func.getName() = "__import__"
  )
}

// Determines if an expression statement is tightly wrapped in try-except blocks
predicate is_tightly_wrapped_in_try_except(ExprStmt exprStmt) {
  // Tight wrapping: try block contains exactly one call statement
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call c | tryBlock.getBody().contains(c)) = 1 and
    exprStmt = tryBlock.getAStmt()
  )
}

// Calculate usage statistics for function calls
predicate calculate_usage_stats(FunctionValue calledFunc, int unusedCount, int totalCount, float usagePercentage) {
  unusedCount = count(ExprStmt e | 
    e.getValue().getAFlowNode() = calledFunc.getACall()
  ) and
  totalCount = count(calledFunc.getACall()) and
  usagePercentage = (100.0 * (totalCount - unusedCount) / totalCount).floor()
}

from ExprStmt funcCall, FunctionValue calledFunc, float usagePercentage, int totalCount
where
  // Match call statements with their called functions
  funcCall.getValue() = calledFunc.getACall().getNode() and
  // Only consider functions that return meaningful values
  func_returns_meaningful_value(calledFunc) and
  // Exclude calls tightly wrapped in try-except blocks
  not is_tightly_wrapped_in_try_except(funcCall) and
  // Calculate and check usage statistics
  calculate_usage_stats(calledFunc, _, totalCount, usagePercentage) and
  /* Report when: at least 5 calls exist and return value is used in ≥75% of calls */
  usagePercentage >= 75 and
  totalCount >= 5
select funcCall,
  "Call discards return value of function $@. The result is used in " + usagePercentage.toString() +
    "% of calls.", calledFunc, calledFunc.getName()