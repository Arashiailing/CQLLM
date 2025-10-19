/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left side 
 *              doesn't match the number of elements in the container on the right side,
 *              which will cause a runtime exception.
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
private int getExpressionListCount(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// Identify assignments with mismatched element counts between LHS and RHS
predicate hasMismatchedAssignment(Assign assignStmt, int leftSideCount, int rightSideCount, Location errorLoc, string containerTypeName) {
  exists(ExprList leftExprList | 
    // Extract LHS tuple/list elements
    (
      assignStmt.getATarget().(Tuple).getElts() = leftExprList or
      assignStmt.getATarget().(List).getElts() = leftExprList
    ) and
    // Handle two possible mismatch scenarios
    (
      // Scenario 1: Explicit container on RHS
      exists(ExprList rightExprList |
        (
          assignStmt.getValue().(Tuple).getElts() = rightExprList and containerTypeName = "tuple"
          or
          assignStmt.getValue().(List).getElts() = rightExprList and containerTypeName = "list"
        ) and
        errorLoc = assignStmt.getValue().getLocation() and
        leftSideCount = getExpressionListCount(leftExprList) and
        rightSideCount = getExpressionListCount(rightExprList) and
        leftSideCount != rightSideCount and
        // Ensure no starred expressions on either side
        not exists(Starred s | 
          leftExprList.getAnItem() = s or rightExprList.getAnItem() = s
        )
      )
      or
      // Scenario 2: Tuple value reference on RHS
      exists(TupleValue tupleValue, AstNode originNode |
        assignStmt.getValue().pointsTo(tupleValue, originNode) and
        containerTypeName = "tuple" and
        errorLoc = originNode.getLocation() and
        leftSideCount = getExpressionListCount(leftExprList) and
        rightSideCount = tupleValue.length() and
        leftSideCount != rightSideCount and
        // Ensure no starred expression on LHS
        not leftExprList.getAnItem() instanceof Starred
      )
    )
  )
}

// Find all assignments with element count mismatches
from Assign assignStmt, int leftSideCount, int rightSideCount, Location errorLoc, string containerTypeName
where hasMismatchedAssignment(assignStmt, leftSideCount, rightSideCount, errorLoc, containerTypeName)
select assignStmt,
  "Left hand side of assignment contains " + leftSideCount +
    " variables, but right hand side is a $@ of length " + rightSideCount + ".", 
  errorLoc, containerTypeName