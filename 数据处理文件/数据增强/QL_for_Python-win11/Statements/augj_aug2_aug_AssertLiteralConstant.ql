/**
 * @name Assertion tests a literal constant
 * @description Detects assertions that check literal values (numbers, strings, or booleans).
 *              These assertions may behave differently under compiler optimizations,
 *              potentially causing unexpected behavior.
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
  // Exclude assertions within test scopes
  not assertNode.getScope().getScope*() instanceof TestScope
  and
  // Identify literal constant expressions in the assertion test
  exists(Expr exprUnderTest | 
    exprUnderTest = assertNode.getTest() and
    (
      // Handle integer literals (converted to string without quotes)
      literalValue = exprUnderTest.(IntegerLiteral).getN().toString()
      or
      // Handle string literals (preserving quotes in output)
      literalValue = "\"" + exprUnderTest.(StringLiteral).getS() + "\""
      or
      // Handle name constants (None, True, False)
      literalValue = exprUnderTest.(NameConstant).toString()
    )
  )
  and
  // Exclude assertions at the end of elif chains
  not exists(If conditionalBlock | 
    conditionalBlock.getElif().getAnOrelse() = assertNode
  )
select assertNode, "Assert of literal constant " + literalValue + "."