/**
 * @name Imprecise assert
 * @description Using 'assertTrue' or 'assertFalse' rather than a more specific assertion can give uninformative failure messages.
 * @kind problem
 * @tags maintainability
 *       testability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/imprecise-assert
 */

import python

/* Helper predicate identifying comparison-based assertion calls */
predicate isComparisonBasedAssert(Call assertCall, string methodName, Cmpop operator) {
  // Verify the call targets assertTrue/assertFalse methods
  assertCall.getFunc().(Attribute).getName() = methodName and
  (methodName = "assertTrue" or methodName = "assertFalse") and
  exists(Compare comparisonExpr |
    // Ensure first argument is a comparison operation
    comparisonExpr = assertCall.getArg(0) and
    /* Exclude chained comparisons like: a < b < c */
    // Reject complex multi-operator comparisons
    not exists(comparisonExpr.getOp(1)) and
    operator = comparisonExpr.getOp(0)
  )
}

class CallToAssertOnComparison extends Call {
  // Constructor matches comparison-based assertions
  CallToAssertOnComparison() { isComparisonBasedAssert(this, _, _) }

  // Retrieve the comparison operator used
  Cmpop getOperator() { isComparisonBasedAssert(this, _, result) }

  // Get the name of the assertion method
  string getMethodName() { isComparisonBasedAssert(this, result, _) }

  // Determine the recommended specific assertion method
  string getBetterName() {
    exists(string currentMethod, Cmpop currentOp |
      currentMethod = this.getMethodName() and
      currentOp = this.getOperator() and
      (
        // Handle assertTrue cases
        currentMethod = "assertTrue" and
        (
          currentOp instanceof Eq and result = "assertEqual"
          or currentOp instanceof NotEq and result = "assertNotEqual"
          or currentOp instanceof Lt and result = "assertLess"
          or currentOp instanceof LtE and result = "assertLessEqual"
          or currentOp instanceof Gt and result = "assertGreater"
          or currentOp instanceof GtE and result = "assertGreaterEqual"
          or currentOp instanceof In and result = "assertIn"
          or currentOp instanceof NotIn and result = "assertNotIn"
          or currentOp instanceof Is and result = "assertIs"
          or currentOp instanceof IsNot and result = "assertIsNot"
        )
        or
        // Handle assertFalse cases
        currentMethod = "assertFalse" and
        (
          currentOp instanceof NotEq and result = "assertEqual"
          or currentOp instanceof Eq and result = "assertNotEqual"
          or currentOp instanceof GtE and result = "assertLess"
          or currentOp instanceof Gt and result = "assertLessEqual"
          or currentOp instanceof LtE and result = "assertGreater"
          or currentOp instanceof Lt and result = "assertGreaterEqual"
          or currentOp instanceof NotIn and result = "assertIn"
          or currentOp instanceof In and result = "assertNotIn"
          or currentOp instanceof IsNot and result = "assertIs"
          or currentOp instanceof Is and result = "assertIsNot"
        )
      )
    )
  }
}

from CallToAssertOnComparison assertCall
where
  /* Exclude assertions with explicit failure messages */
  // Filter out cases where custom message is provided
  not exists(assertCall.getArg(1))
select assertCall,
  // Generate recommendation message with specific assertion alternatives
  assertCall.getMethodName() + "(a " + assertCall.getOperator().getSymbol() + " b) " +
    "cannot provide an informative message. Using " + assertCall.getBetterName() +
    "(a, b) instead will give more informative messages."