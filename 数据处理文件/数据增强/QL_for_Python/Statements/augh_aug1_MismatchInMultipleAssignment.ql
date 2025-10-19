/**
 * @name Multiple Assignment Length Mismatch
 * @description Detects assignments where the number of variables on the left-hand side
 *              does not match the number of values on the right-hand side, which would
 *              cause a ValueError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mismatched-multiple-assignment
 */

import python

// Counts the number of items in an expression list
private int countExprListItems(ExprList expressionList) { 
  result = count(expressionList.getAnItem()) 
}

// Detects assignments where the number of variables on the left doesn't match the number of values on the right
predicate mismatchedAssignment(Assign assignment, int leftSideCount, int rightSideCount, Location errorLoc, string containerKind) {
  exists(ExprList leftExprList | 
    // Get the tuple or list elements on the left side of the assignment
    (
      assignment.getATarget().(Tuple).getElts() = leftExprList or
      assignment.getATarget().(List).getElts() = leftExprList
    ) and
    // Handle cases where the right side is an explicit container
    (exists(ExprList rightExprList |
      (
        assignment.getValue().(Tuple).getElts() = rightExprList and containerKind = "tuple"
        or
        assignment.getValue().(List).getElts() = rightExprList and containerKind = "list"
      ) and
      errorLoc = assignment.getValue().getLocation() and
      leftSideCount = countExprListItems(leftExprList) and
      rightSideCount = countExprListItems(rightExprList) and
      leftSideCount != rightSideCount and
      // Ensure neither side contains starred expressions
      not exists(Starred s | 
        leftExprList.getAnItem() = s or rightExprList.getAnItem() = s
      )
    )
    or
    // Handle cases where the right side is a reference to a tuple value
    exists(TupleValue tupleVal, AstNode sourceNode |
      assignment.getValue().pointsTo(tupleVal, sourceNode) and
      containerKind = "tuple" and
      errorLoc = sourceNode.getLocation() and
      leftSideCount = countExprListItems(leftExprList) and
      rightSideCount = tupleVal.length() and
      leftSideCount != rightSideCount and
      // Ensure the left side doesn't contain starred expressions
      not leftExprList.getAnItem() instanceof Starred
    ))
  )
}

// Find all assignments with a mismatch in the number of elements
from Assign assignment, int leftSideCount, int rightSideCount, Location errorLoc, string containerKind
where mismatchedAssignment(assignment, leftSideCount, rightSideCount, errorLoc, containerKind)
select assignment,
  "Left hand side of assignment contains " + leftSideCount +
    " variables, but right hand side is a $@ of length " + rightSideCount + ".", 
  errorLoc, containerKind