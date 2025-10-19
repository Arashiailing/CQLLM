/**
 * @name Assert statement tests the truth value of a literal constant
 * @description An assert statement testing a literal constant value may exhibit
 *              different behavior when optimizations are enabled.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/assert-literal-constant
 */

import python
import semmle.python.filters.Tests

from Assert assertion, string constantValue
where
  // Filter out test case assertions by examining scope hierarchy
  not assertion.getScope().getScope*() instanceof TestScope and
  // Extract literal constant expressions from the assertion test
  exists(Expr assertionTestExpr | 
    assertionTestExpr = assertion.getTest() and (
      // Process integer literal values
      constantValue = assertionTestExpr.(IntegerLiteral).getN() or
      // Process string literals with enclosing quotes
      constantValue = "\"" + assertionTestExpr.(StringLiteral).getS() + "\"" or
      // Process named constants (None, True, False)
      constantValue = assertionTestExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions positioned at the end of elif chains
  not exists(If conditionalStmt | 
    conditionalStmt.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."