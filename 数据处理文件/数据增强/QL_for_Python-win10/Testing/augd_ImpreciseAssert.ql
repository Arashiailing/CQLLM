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
predicate isImpreciseAssertCall(Call assertionCall, string methodName, Cmpop comparisonOp) {
  // Verify the function call is to assertTrue/assertFalse
  assertionCall.getFunc().(Attribute).getName() = methodName and
  (methodName = "assertTrue" or methodName = "assertFalse") and
  exists(Compare comparisonExpr |
    // First argument must be a comparison operation
    comparisonExpr = assertionCall.getArg(0) and
    /* Exclude chained comparisons (e.g., a < b < c) */
    not exists(comparisonExpr.getOp(1)) and
    comparisonOp = comparisonExpr.getOp(0)
  )
}

class ImpreciseAssertCall extends Call {
  ImpreciseAssertCall() { isImpreciseAssertCall(this, _, _) }

  // Retrieve the comparison operator used in the assertion
  Cmpop getComparisonOperator() { isImpreciseAssertCall(this, _, result) }

  // Get the name of the assertion method
  string getAssertionMethod() { isImpreciseAssertCall(this, result, _) }

  // Determine the appropriate specific assertion method
  string getRecommendedMethod() {
    exists(Cmpop operator |
      isImpreciseAssertCall(this, "assertTrue", operator) and
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
      isImpreciseAssertCall(this, "assertFalse", operator) and
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

from ImpreciseAssertCall impreciseCall
where
  /* Exclude assertions with custom failure messages */
  not exists(impreciseCall.getArg(1))
select impreciseCall,
  impreciseCall.getAssertionMethod() + "(a " + impreciseCall.getComparisonOperator().getSymbol() + " b) " +
    "cannot provide an informative message. Using " + impreciseCall.getRecommendedMethod() +
    "(a, b) instead will give more informative messages."