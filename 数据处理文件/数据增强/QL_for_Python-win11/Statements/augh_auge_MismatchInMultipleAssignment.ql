/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left
 *              doesn't match the number of elements on the right, causing runtime exceptions.
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

// Check for element count mismatch in assignments
predicate hasMismatchedAssignment(Assign assignmentStmt, int lhsElementCount, int rhsElementCount, 
                                Location errorLocation, string rhsSequenceType) {
  // Case 1: Direct sequence assignment (tuple/list literals)
  exists(ExprList lhsItems, ExprList rhsItems |
    // Verify left-hand side is a tuple or list
    (
      assignmentStmt.getATarget().(Tuple).getElts() = lhsItems or
      assignmentStmt.getATarget().(List).getElts() = lhsItems
    ) and
    // Verify right-hand side is a tuple or list
    (
      (assignmentStmt.getValue().(Tuple).getElts() = rhsItems and rhsSequenceType = "tuple") or
      (assignmentStmt.getValue().(List).getElts() = rhsItems and rhsSequenceType = "list")
    ) and
    // Get error location and count elements
    errorLocation = assignmentStmt.getValue().getLocation() and
    lhsElementCount = count(lhsItems.getAnItem()) and
    rhsElementCount = count(rhsItems.getAnItem()) and
    // Validate mismatch and absence of starred expressions
    lhsElementCount != rhsElementCount and
    not exists(Starred starredExpr | 
      lhsItems.getAnItem() = starredExpr or rhsItems.getAnItem() = starredExpr
    )
  )
  or
  // Case 2: Assignment to tuple value (semantic analysis)
  exists(ExprList lhsItems, TupleValue rhsTupleValue, AstNode valueOrigin |
    // Verify left-hand side is a tuple or list
    (
      assignmentStmt.getATarget().(Tuple).getElts() = lhsItems or
      assignmentStmt.getATarget().(List).getElts() = lhsItems
    ) and
    // Verify right-hand side points to a tuple value
    assignmentStmt.getValue().pointsTo(rhsTupleValue, valueOrigin) and
    // Get error location and count elements
    errorLocation = valueOrigin.getLocation() and
    lhsElementCount = count(lhsItems.getAnItem()) and
    rhsElementCount = rhsTupleValue.length() and
    // Validate mismatch and absence of starred expressions
    lhsElementCount != rhsElementCount and
    not lhsItems.getAnItem() instanceof Starred and
    rhsSequenceType = "tuple"
  )
}

// Find all assignments with element count mismatches
from Assign assignmentStmt, int lhsElementCount, int rhsElementCount, 
     Location errorLocation, string rhsSequenceType
where 
  hasMismatchedAssignment(assignmentStmt, lhsElementCount, rhsElementCount, errorLocation, rhsSequenceType)
select assignmentStmt,
  "Left hand side of assignment contains " + lhsElementCount +
    " variables, but right hand side is a $@ of length " + rhsElementCount + ".", 
  errorLocation, rhsSequenceType