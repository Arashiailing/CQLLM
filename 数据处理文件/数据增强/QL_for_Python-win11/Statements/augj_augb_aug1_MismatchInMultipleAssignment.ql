/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left 
 *              doesn't match the number of elements in the right-hand container
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

// Calculate total elements in an expression list
private int calculateExprListCount(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// Identify assignments with mismatched element counts between LHS and RHS
predicate assignmentMismatch(Assign assignment, int leftCount, int rightCount, Location loc, string containerType) {
  exists(ExprList lhsExprList | 
    // Extract LHS tuple/list elements
    (
      assignment.getATarget().(Tuple).getElts() = lhsExprList or
      assignment.getATarget().(List).getElts() = lhsExprList
    ) and
    leftCount = calculateExprListCount(lhsExprList) and
    // Handle explicit RHS containers
    (exists(ExprList rhsExprList |
      (
        assignment.getValue().(Tuple).getElts() = rhsExprList and containerType = "tuple"
        or
        assignment.getValue().(List).getElts() = rhsExprList and containerType = "list"
      ) and
      loc = assignment.getValue().getLocation() and
      rightCount = calculateExprListCount(rhsExprList) and
      leftCount != rightCount and
      // Ensure no starred expressions on either side
      not exists(Starred s | 
        lhsExprList.getAnItem() = s or rhsExprList.getAnItem() = s
      )
    )
    or
    // Handle tuple value references on RHS
    exists(TupleValue tupleVal, AstNode sourceNode |
      assignment.getValue().pointsTo(tupleVal, sourceNode) and
      containerType = "tuple" and
      loc = sourceNode.getLocation() and
      rightCount = tupleVal.length() and
      leftCount != rightCount and
      // Ensure no starred expressions on LHS
      not lhsExprList.getAnItem() instanceof Starred
    ))
  )
}

// Find all assignments with element count mismatches
from Assign assignment, int leftCount, int rightCount, Location loc, string containerType
where assignmentMismatch(assignment, leftCount, rightCount, loc, containerType)
select assignment,
  "Left hand side has " + leftCount +
    " variables, but right hand side is a $@ with " + rightCount + " elements.", 
  loc, containerType