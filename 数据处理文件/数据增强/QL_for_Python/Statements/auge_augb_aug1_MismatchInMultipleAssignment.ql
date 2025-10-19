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

// 计算表达式列表中的元素数量
private int countElementsInList(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// 检测赋值语句左右两侧元素数量不匹配的情况
predicate assignmentLengthMismatch(Assign assignment, int leftCount, int rightCount, Location errorLocation, string containerType) {
  exists(ExprList leftExprList | 
    // 获取赋值左侧的元组或列表元素
    (
      assignment.getATarget().(Tuple).getElts() = leftExprList or
      assignment.getATarget().(List).getElts() = leftExprList
    ) and
    leftCount = countElementsInList(leftExprList) and
    // 处理右侧为显式容器的情况
    (exists(ExprList rightExprList |
      (
        assignment.getValue().(Tuple).getElts() = rightExprList and containerType = "tuple"
        or
        assignment.getValue().(List).getElts() = rightExprList and containerType = "list"
      ) and
      errorLocation = assignment.getValue().getLocation() and
      rightCount = countElementsInList(rightExprList) and
      leftCount != rightCount and
      // 确保两侧均无星号表达式
      not exists(Starred s | 
        leftExprList.getAnItem() = s or rightExprList.getAnItem() = s
      )
    )
    or
    // 处理右侧为元组值引用的情况
    exists(TupleValue tupleValue, AstNode originNode |
      assignment.getValue().pointsTo(tupleValue, originNode) and
      containerType = "tuple" and
      errorLocation = originNode.getLocation() and
      rightCount = tupleValue.length() and
      leftCount != rightCount and
      // 确保左侧无星号表达式
      not leftExprList.getAnItem() instanceof Starred
    ))
  )
}

// 查询所有存在元素数量不匹配的赋值语句
from Assign assignStmt, int lhsCount, int rhsCount, Location loc, string containerKind
where assignmentLengthMismatch(assignStmt, lhsCount, rhsCount, loc, containerKind)
select assignStmt,
  "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
  loc, containerKind