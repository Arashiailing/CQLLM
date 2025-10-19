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
predicate isComparisonBasedAssert(Call assertCall, string methodName, Cmpop comparisonOperator) {
  // Verify the call targets assertTrue/assertFalse methods
  assertCall.getFunc().(Attribute).getName() = methodName and
  (methodName = "assertTrue" or methodName = "assertFalse") and
  exists(Compare comparisonExpr |
    // Ensure first argument is a comparison operation
    comparisonExpr = assertCall.getArg(0) and
    /* Exclude chained comparisons like: a < b < c */
    // Reject complex multi-operator comparisons
    not exists(comparisonExpr.getOp(1)) and
    comparisonOperator = comparisonExpr.getOp(0)
  )
}

class CallToAssertOnComparison extends Call {
  // Constructor matches comparison-based assertions
  CallToAssertOnComparison() { isComparisonBasedAssert(this, _, _) }

  // Retrieve the comparison operator used
  Cmpop getOperator() { isComparisonBasedAssert(this, _, result) }

  // Get the name of the assertion method
  string getMethodName() { isComparisonBasedAssert(this, result, _) }

  // Determine recommended assertion method for assertTrue cases
  private string getTrueAssertAlternative(Cmpop operator) {
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
  }

  // Determine recommended assertion method for assertFalse cases
  private string getFalseAssertAlternative(Cmpop operator) {
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
  }

  // Determine the recommended specific assertion method
  string getBetterName() {
    exists(Cmpop operator |
      operator = this.getOperator() and
      (
        this.getMethodName() = "assertTrue" and 
        result = this.getTrueAssertAlternative(operator)
        or
        this.getMethodName() = "assertFalse" and 
        result = this.getFalseAssertAlternative(operator)
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