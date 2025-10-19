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
predicate isComparisonBasedAssert(Call targetCall, string assertMethodName, Cmpop op) {
  // Verify the call targets assertTrue/assertFalse methods
  targetCall.getFunc().(Attribute).getName() = assertMethodName and
  (assertMethodName = "assertTrue" or assertMethodName = "assertFalse") and
  exists(Compare compareExpr |
    // Ensure first argument is a comparison operation
    compareExpr = targetCall.getArg(0) and
    /* Exclude chained comparisons like: a < b < c */
    // Reject complex multi-operator comparisons
    not exists(compareExpr.getOp(1)) and
    op = compareExpr.getOp(0)
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
    exists(Cmpop cmpOperator |
      // Handle assertTrue cases
      isComparisonBasedAssert(this, "assertTrue", cmpOperator) and
      (
        cmpOperator instanceof Eq and result = "assertEqual"
        or
        cmpOperator instanceof NotEq and result = "assertNotEqual"
        or
        cmpOperator instanceof Lt and result = "assertLess"
        or
        cmpOperator instanceof LtE and result = "assertLessEqual"
        or
        cmpOperator instanceof Gt and result = "assertGreater"
        or
        cmpOperator instanceof GtE and result = "assertGreaterEqual"
        or
        cmpOperator instanceof In and result = "assertIn"
        or
        cmpOperator instanceof NotIn and result = "assertNotIn"
        or
        cmpOperator instanceof Is and result = "assertIs"
        or
        cmpOperator instanceof IsNot and result = "assertIsNot"
      )
      or
      // Handle assertFalse cases
      isComparisonBasedAssert(this, "assertFalse", cmpOperator) and
      (
        cmpOperator instanceof NotEq and result = "assertEqual"
        or
        cmpOperator instanceof Eq and result = "assertNotEqual"
        or
        cmpOperator instanceof GtE and result = "assertLess"
        or
        cmpOperator instanceof Gt and result = "assertLessEqual"
        or
        cmpOperator instanceof LtE and result = "assertGreater"
        or
        cmpOperator instanceof Lt and result = "assertGreaterEqual"
        or
        cmpOperator instanceof NotIn and result = "assertIn"
        or
        cmpOperator instanceof In and result = "assertNotIn"
        or
        cmpOperator instanceof IsNot and result = "assertIs"
        or
        cmpOperator instanceof Is and result = "assertIsNot"
      )
    )
  }
}

from CallToAssertOnComparison targetCall
where
  /* Exclude assertions with explicit failure messages */
  // Filter out cases where custom message is provided
  not exists(targetCall.getArg(1))
select targetCall,
  // Generate recommendation message with specific assertion alternatives
  targetCall.getMethodName() + "(a " + targetCall.getOperator().getSymbol() + " b) " +
    "cannot provide an informative message. Using " + targetCall.getBetterName() +
    "(a, b) instead will give more informative messages."