/**
 * @name Mismatch in multiple assignment
 * @description Assigning multiple variables without ensuring that you define a
 *              value for each variable causes an exception at runtime.
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
private int countElements(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// Detect assignment mismatches between left-hand and right-hand side elements
predicate assignmentMismatch(Assign assignment, int lhsCount, int rhsCount, Location location, string seqType) {
  exists(ExprList lhsElements, ExprList rhsElements |
    // Check if assignment target is a tuple or list
    (
      assignment.getATarget().(Tuple).getElts() = lhsElements or
      assignment.getATarget().(List).getElts() = lhsElements
    ) and
    // Check if assignment value is a tuple or list
    (
      (assignment.getValue().(Tuple).getElts() = rhsElements and seqType = "tuple") or
      (assignment.getValue().(List).getElts() = rhsElements and seqType = "list")
    ) and
    // Get location of the assignment value
    location = assignment.getValue().getLocation() and
    // Count elements on both sides
    lhsCount = countElements(lhsElements) and
    rhsCount = countElements(rhsElements) and
    // Verify element count mismatch
    lhsCount != rhsCount and
    // Ensure no starred expressions are used
    not exists(Starred s | lhsElements.getAnItem() = s or rhsElements.getAnItem() = s)
  )
  or
  // Handle cases where right-hand side points to a tuple value
  exists(ExprList lhsElements, TupleValue rhsTuple, AstNode origin |
    // Check if assignment target is a tuple or list
    (
      assignment.getATarget().(Tuple).getElts() = lhsElements or
      assignment.getATarget().(List).getElts() = lhsElements
    ) and
    // Check if assignment value points to a tuple
    assignment.getValue().pointsTo(rhsTuple, origin) and
    // Get location of the tuple origin
    location = origin.getLocation() and
    // Count elements on both sides
    lhsCount = countElements(lhsElements) and
    rhsCount = rhsTuple.length() and
    // Verify element count mismatch
    lhsCount != rhsCount and
    // Ensure no starred expressions on left-hand side
    not lhsElements.getAnItem() instanceof Starred and
    // Set sequence type as tuple
    seqType = "tuple"
  )
}

// Find all assignments with mismatched element counts
from Assign assignment, int lhsCount, int rhsCount, Location location, string seqType
where assignmentMismatch(assignment, lhsCount, rhsCount, location, seqType)
select assignment,
  "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", location, seqType