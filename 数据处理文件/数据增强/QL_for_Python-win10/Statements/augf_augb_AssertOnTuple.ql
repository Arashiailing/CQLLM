/**
 * @name Asserting a tuple
 * @description Detects assert statements that test tuples, which provide no meaningful validity checking.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-670
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/asserts-tuple
 */

import python

// Identify all assert statements in the code that test tuple expressions.
from Assert assertStatement, string evaluationResult, string tupleDescription
where
  // Check if the expression being asserted is a tuple.
  assertStatement.getTest() instanceof Tuple and
  (
    // For non-empty tuples, the assertion always evaluates to True.
    if exists(assertStatement.getTest().(Tuple).getAnElt())
    then (
      evaluationResult = "True" and tupleDescription = "non-"
    ) else (
      // For empty tuples, the assertion always evaluates to False.
      evaluationResult = "False" and tupleDescription = ""
    )
  )
// Generate a warning message for each identified assert statement.
select assertStatement, "Assertion of " + tupleDescription + "empty tuple is always " + evaluationResult + "."