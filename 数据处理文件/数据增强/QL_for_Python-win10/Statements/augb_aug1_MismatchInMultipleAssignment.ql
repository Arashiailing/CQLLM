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

// 计算表达式列表中的元素总数
private int countExprListItems(ExprList expressionList) { 
  result = count(expressionList.getAnItem()) 
}

// 检测赋值语句中左右两侧元素数量不匹配的情况
predicate mismatchedAssignment(Assign assignStmt, int lhsCount, int rhsCount, Location loc, string containerKind) {
  exists(ExprList leftExprList | 
    // 获取赋值左侧的元组或列表元素
    (
      assignStmt.getATarget().(Tuple).getElts() = leftExprList or
      assignStmt.getATarget().(List).getElts() = leftExprList
    ) and
    lhsCount = countExprListItems(leftExprList) and
    // 处理右侧为显式容器的情况
    (exists(ExprList rightExprList |
      (
        assignStmt.getValue().(Tuple).getElts() = rightExprList and containerKind = "tuple"
        or
        assignStmt.getValue().(List).getElts() = rightExprList and containerKind = "list"
      ) and
      loc = assignStmt.getValue().getLocation() and
      rhsCount = countExprListItems(rightExprList) and
      lhsCount != rhsCount and
      // 确保两侧均无星号表达式
      not exists(Starred s | 
        leftExprList.getAnItem() = s or rightExprList.getAnItem() = s
      )
    )
    or
    // 处理右侧为元组值引用的情况
    exists(TupleValue tupleValue, AstNode originNode |
      assignStmt.getValue().pointsTo(tupleValue, originNode) and
      containerKind = "tuple" and
      loc = originNode.getLocation() and
      rhsCount = tupleValue.length() and
      lhsCount != rhsCount and
      // 确保左侧无星号表达式
      not leftExprList.getAnItem() instanceof Starred
    ))
  )
}

// 查询所有存在元素数量不匹配的赋值语句
from Assign assignStmt, int lhsCount, int rhsCount, Location loc, string containerKind
where mismatchedAssignment(assignStmt, lhsCount, rhsCount, loc, containerKind)
select assignStmt,
  "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
  loc, containerKind