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

/* Helper predicate identifying assertion calls with comparison operations */
predicate isAssertCallWithComparison(Call assertionCall, string assertionMethod, Cmpop comparisonOperator) {
  // Verify the call targets assertTrue/assertFalse methods
  assertionCall.getFunc().(Attribute).getName() = assertionMethod and
  (assertionMethod = "assertTrue" or assertionMethod = "assertFalse") and
  exists(Compare comparisonExpr |
    // Ensure first argument is a comparison operation
    comparisonExpr = assertionCall.getArg(0) and
    /* Exclude chained comparisons like: a < b < c */
    not exists(comparisonExpr.getOp(1)) and
    comparisonOperator = comparisonExpr.getOp(0)
  )
}

class CallToAssertOnComparison extends Call {
  CallToAssertOnComparison() { isAssertCallWithComparison(this, _, _) }

  // Retrieve the comparison operator used in the assertion
  Cmpop getComparisonOperator() { isAssertCallWithComparison(this, _, result) }

  // Get the name of the assertion method (assertTrue/assertFalse)
  string getAssertionMethodName() { isAssertCallWithComparison(this, result, _) }

  // Determine the more appropriate assertion method to use
  string getRecommendedAssertion() {
    exists(Cmpop operator |
      // Handle assertTrue cases
      isAssertCallWithComparison(this, "assertTrue", operator) and
      (
        operator instanceof Eq and result = "assertEqual"
        or
        operator instanceof NotEq and result = "assertNotEqual"
        or
        operator instanceof Lt and result = "assertLess"
        or
        operator instanceof LtE and result = "assertLessEqual"
        or
        operator instanceof Gt and result = "assertGreater"
        or
        operator instanceof GtE and result = "assertGreaterEqual"
        or
        operator instanceof In and result = "assertIn"
        or
        operator instanceof NotIn and result = "assertNotIn"
        or
        operator instanceof Is and result = "assertIs"
        or
        operator instanceof IsNot and result = "assertIsNot"
      )
      or
      // Handle assertFalse cases
      isAssertCallWithComparison(this, "assertFalse", operator) and
      (
        operator instanceof NotEq and result = "assertEqual"
        or
        operator instanceof Eq and result = "assertNotEqual"
        or
        operator instanceof GtE and result = "assertLess"
        or
        operator instanceof Gt and result = "assertLessEqual"
        or
        operator instanceof LtE and result = "assertGreater"
        or
        operator instanceof Lt and result = "assertGreaterEqual"
        or
        operator instanceof NotIn and result = "assertIn"
        or
        operator instanceof In and result = "assertNotIn"
        or
        operator instanceof IsNot and result = "assertIs"
        or
        operator instanceof Is and result = "assertIsNot"
      )
    )
  }
}

from CallToAssertOnComparison problematicCall
where
  /* Exclude cases where custom failure message is provided */
  not exists(problematicCall.getArg(1))
select problematicCall,
  // Generate recommendation message with operator symbol
  problematicCall.getAssertionMethodName() + "(a " + problematicCall.getComparisonOperator().getSymbol() + " b) " +
    "cannot provide an informative message. Using " + problematicCall.getRecommendedAssertion() +
    "(a, b) instead will give more informative messages."