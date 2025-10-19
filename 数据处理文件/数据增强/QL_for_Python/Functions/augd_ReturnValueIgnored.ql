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

// Determines if a returned expression has meaningful value
predicate meaningful_return_value(Expr returnedValue) {
  // Consider names and boolean literals as meaningful
  returnedValue instanceof Name
  or
  returnedValue instanceof BooleanLiteral
  or
  // Function calls returning meaningful values are considered meaningful
  exists(FunctionValue calledFunction |
    returnedValue = calledFunction.getACall().getNode() and 
    returns_meaningful_value(calledFunction)
  )
  or
  // Non-call expressions that aren't simple names are considered meaningful
  not exists(FunctionValue calledFunction | 
    returnedValue = calledFunction.getACall().getNode()
  ) and 
  not returnedValue instanceof Name
}

/* Value is used before returning, indicating its value isn't lost if ignored */
// Determines if a returned value is actually used elsewhere
predicate used_value(Expr returnedValue) {
  // Value is used if accessed through a local variable in other locations
  exists(LocalVariable localVar, Expr otherAccess |
    localVar.getAnAccess() = returnedValue and 
    otherAccess = localVar.getAnAccess() and 
    not otherAccess = returnedValue
  )
}

// Determines if a function returns meaningful values
predicate returns_meaningful_value(FunctionValue func) {
  // Functions without fallthrough nodes (e.g., with exception handling)
  not exists(func.getScope().getFallthroughNode()) and
  (
    // Functions with meaningful return statements that aren't used
    exists(Return returnStmt, Expr returnedValue | 
      returnStmt.getScope() = func.getScope() and 
      returnedValue = returnStmt.getValue()
    |
      meaningful_return_value(returnedValue) and
      not used_value(returnedValue)
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

/* Calls wrapped tightly in try-except blocks are assumed to be for exception handling */
// Determines if an expression statement is tightly wrapped in try-except
predicate wrapped_in_try_except(ExprStmt callStmt) {
  // Tight wrapping: try block contains exactly one call statement
  exists(Try tryBlock |
    exists(tryBlock.getAHandler()) and
    strictcount(Call c | tryBlock.getBody().contains(c)) = 1 and
    callStmt = tryBlock.getAStmt()
  )
}

from ExprStmt callStmt, FunctionValue calledFunction, float usagePercentage, int totalCalls
where
  // Match call statements with their called functions
  callStmt.getValue() = calledFunction.getACall().getNode() and
  // Only consider functions returning meaningful values
  returns_meaningful_value(calledFunction) and
  // Exclude calls tightly wrapped in try-except blocks
  not wrapped_in_try_except(callStmt) and
  // Calculate usage statistics for the function calls
  exists(int unusedCalls |
    unusedCalls = count(ExprStmt e | 
      e.getValue().getAFlowNode() = calledFunction.getACall()
    ) and
    totalCalls = count(calledFunction.getACall())
  |
    usagePercentage = (100.0 * (totalCalls - unusedCalls) / totalCalls).floor()
  ) and
  /* Report when: at least 5 calls exist and return value is used in ≥75% of calls */
  usagePercentage >= 75 and
  totalCalls >= 5
select callStmt,
  "Call discards return value of function $@. The result is used in " + usagePercentage.toString() +
    "% of calls.", calledFunction, calledFunction.getName()