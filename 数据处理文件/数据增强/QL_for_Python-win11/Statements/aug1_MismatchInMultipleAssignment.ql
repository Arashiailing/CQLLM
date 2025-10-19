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
private int exprListLength(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// 检测赋值语句中左右两侧元素数量不匹配的情况
predicate mismatchedAssignment(Assign assignStmt, int lhsCount, int rhsCount, Location errorLocation, string containerType) {
  exists(ExprList lhsExprList | 
    // 获取赋值左侧的元组或列表元素
    (
      assignStmt.getATarget().(Tuple).getElts() = lhsExprList or
      assignStmt.getATarget().(List).getElts() = lhsExprList
    ) and
    // 处理右侧为显式容器的情况
    (exists(ExprList rhsExprList |
      (
        assignStmt.getValue().(Tuple).getElts() = rhsExprList and containerType = "tuple"
        or
        assignStmt.getValue().(List).getElts() = rhsExprList and containerType = "list"
      ) and
      errorLocation = assignStmt.getValue().getLocation() and
      lhsCount = exprListLength(lhsExprList) and
      rhsCount = exprListLength(rhsExprList) and
      lhsCount != rhsCount and
      // 确保两侧均无星号表达式
      not exists(Starred s | 
        lhsExprList.getAnItem() = s or rhsExprList.getAnItem() = s
      )
    )
    or
    // 处理右侧为元组值引用的情况
    exists(TupleValue tupleValue, AstNode originNode |
      assignStmt.getValue().pointsTo(tupleValue, originNode) and
      containerType = "tuple" and
      errorLocation = originNode.getLocation() and
      lhsCount = exprListLength(lhsExprList) and
      rhsCount = tupleValue.length() and
      lhsCount != rhsCount and
      // 确保左侧无星号表达式
      not lhsExprList.getAnItem() instanceof Starred
    ))
  )
}

// 查询所有存在元素数量不匹配的赋值语句
from Assign assignStmt, int lhsCount, int rhsCount, Location errorLocation, string containerType
where mismatchedAssignment(assignStmt, lhsCount, rhsCount, errorLocation, containerType)
select assignStmt,
  "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
  errorLocation, containerType