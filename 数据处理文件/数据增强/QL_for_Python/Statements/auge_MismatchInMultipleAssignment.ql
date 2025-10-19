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

// Calculate the number of elements in an expression list
private int calculateLength(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// Check for element count mismatch in direct sequence assignments
predicate mismatched(Assign assignmentStmt, int lhsElementCount, int rhsElementCount, 
                    Location errorLocation, string rhsSequenceType) {
  exists(ExprList lhsExprList, ExprList rhsExprList |
    // Verify left-hand side is a tuple or list and extract its elements
    (
      assignmentStmt.getATarget().(Tuple).getElts() = lhsExprList or
      assignmentStmt.getATarget().(List).getElts() = lhsExprList
    ) and
    // Verify right-hand side is a tuple or list and extract its elements
    (
      (assignmentStmt.getValue().(Tuple).getElts() = rhsExprList and rhsSequenceType = "tuple") or
      (assignmentStmt.getValue().(List).getElts() = rhsExprList and rhsSequenceType = "list")
    ) and
    // Get the location of the assignment value
    errorLocation = assignmentStmt.getValue().getLocation() and
    // Count elements on both sides
    lhsElementCount = calculateLength(lhsExprList) and
    rhsElementCount = calculateLength(rhsExprList) and
    // Check for element count mismatch
    lhsElementCount != rhsElementCount and
    // Ensure no starred expressions are used
    not exists(Starred starredExpr | 
      lhsExprList.getAnItem() = starredExpr or rhsExprList.getAnItem() = starredExpr
    )
  )
}

// Check for element count mismatch when right-hand side points to a tuple value
predicate mismatched_tuple_rhs(Assign assignmentStmt, int lhsElementCount, int rhsElementCount, 
                              Location errorLocation) {
  exists(ExprList lhsExprList, TupleValue rhsTupleValue, AstNode valueOrigin |
    // Verify left-hand side is a tuple or list and extract its elements
    (
      assignmentStmt.getATarget().(Tuple).getElts() = lhsExprList or
      assignmentStmt.getATarget().(List).getElts() = lhsExprList
    ) and
    // Verify right-hand side points to a tuple value
    assignmentStmt.getValue().pointsTo(rhsTupleValue, valueOrigin) and
    // Get the location of the value origin
    errorLocation = valueOrigin.getLocation() and
    // Count elements on both sides
    lhsElementCount = calculateLength(lhsExprList) and
    rhsElementCount = rhsTupleValue.length() and
    // Check for element count mismatch
    lhsElementCount != rhsElementCount and
    // Ensure no starred expressions on the left
    not lhsExprList.getAnItem() instanceof Starred
  )
}

// Find all assignments with element count mismatches
from Assign assignmentStmt, int lhsElementCount, int rhsElementCount, 
     Location errorLocation, string rhsSequenceType
where
  // Check for direct sequence assignment mismatch
  mismatched(assignmentStmt, lhsElementCount, rhsElementCount, errorLocation, rhsSequenceType)
  or
  // Check for tuple value assignment mismatch
  mismatched_tuple_rhs(assignmentStmt, lhsElementCount, rhsElementCount, errorLocation) and
  rhsSequenceType = "tuple"
select assignmentStmt,
  // Generate problem description message
  "Left hand side of assignment contains " + lhsElementCount +
    " variables, but right hand side is a $@ of length " + rhsElementCount + ".", 
  errorLocation, rhsSequenceType