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

// Helper to count elements in an expression list
private int countElements(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// Detect mismatches in direct sequence assignments (tuple/list)
predicate sequenceMismatch(Assign assignment, int leftSize, int rightSize, 
                          Location errorLoc, string sequenceType) {
  exists(ExprList leftExprs, ExprList rightExprs |
    // Left side must be tuple or list
    (
      assignment.getATarget().(Tuple).getElts() = leftExprs or
      assignment.getATarget().(List).getElts() = leftExprs
    ) and
    // Right side must be tuple or list
    (
      (assignment.getValue().(Tuple).getElts() = rightExprs and sequenceType = "tuple") or
      (assignment.getValue().(List).getElts() = rightExprs and sequenceType = "list")
    ) and
    // Capture error location and sizes
    errorLoc = assignment.getValue().getLocation() and
    leftSize = countElements(leftExprs) and
    rightSize = countElements(rightExprs) and
    // Validate mismatch condition
    leftSize != rightSize and
    // Exclude starred expressions
    not exists(Starred starred | 
      leftExprs.getAnItem() = starred or rightExprs.getAnItem() = starred
    )
  )
}

// Detect mismatches when RHS references a tuple value
predicate tupleValueMismatch(Assign assignment, int leftSize, int rightSize, 
                            Location errorLoc, string sequenceType) {
  exists(ExprList leftExprs, TupleValue tupleVal, AstNode valueSource |
    // Left side must be tuple or list
    (
      assignment.getATarget().(Tuple).getElts() = leftExprs or
      assignment.getATarget().(List).getElts() = leftExprs
    ) and
    // RHS must point to a tuple value
    assignment.getValue().pointsTo(tupleVal, valueSource) and
    // Capture error location and sizes
    errorLoc = valueSource.getLocation() and
    leftSize = countElements(leftExprs) and
    rightSize = tupleVal.length() and
    // Validate mismatch condition
    leftSize != rightSize and
    // Exclude starred expressions on LHS
    not leftExprs.getAnItem() instanceof Starred and
    // Set sequence type
    sequenceType = "tuple"
  )
}

// Find all assignments with element count mismatches
from Assign assignment, int leftSize, int rightSize, 
     Location errorLoc, string sequenceType
where
  // Check direct sequence mismatches
  sequenceMismatch(assignment, leftSize, rightSize, errorLoc, sequenceType)
  or
  // Check tuple value mismatches
  tupleValueMismatch(assignment, leftSize, rightSize, errorLoc, sequenceType)
select assignment,
  // Generate problem description message
  "Left hand side of assignment contains " + leftSize +
    " variables, but right hand side is a $@ of length " + rightSize + ".", 
  errorLoc, sequenceType