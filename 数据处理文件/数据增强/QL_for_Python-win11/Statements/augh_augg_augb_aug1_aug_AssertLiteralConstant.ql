/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Identifies assert statements that check literal constant values,
 *              which might exhibit unexpected behavior under compiler optimizations.
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

from Assert assertNode, string literalValue
where
  // Skip assertions inside test scopes to minimize false positives
  not assertNode.getScope().getScope*() instanceof TestScope
  and
  // Verify if the assert statement evaluates a literal constant
  exists(Expr testExpr | 
    testExpr = assertNode.getTest() and (
      // Process integer literals
      literalValue = testExpr.(IntegerLiteral).getN()
      or
      // Process string literals with escaped quotes
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      // Process name constants (None, True, False)
      literalValue = testExpr.(NameConstant).toString()
    )
  )
  and
  // Exclude assertions positioned at the end of elif branches
  not exists(If conditional | 
    conditional.getElif().getAnOrelse() = assertNode
  )
select assertNode, "Assert of literal constant " + literalValue + "."