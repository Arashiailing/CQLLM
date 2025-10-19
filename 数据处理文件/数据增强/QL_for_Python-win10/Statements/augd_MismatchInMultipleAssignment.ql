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

// 计算表达式列表的长度
private int exprListLength(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// 检查直接解包赋值时的元素数量不匹配情况
predicate directUnpackMismatch(Assign assignment, int lhsCount, int rhsCount, Location location, string sequenceType) {
  exists(ExprList lhsExprList, ExprList rhsExprList |
    // 处理左侧为元组或列表的情况
    (
      assignment.getATarget().(Tuple).getElts() = lhsExprList or
      assignment.getATarget().(List).getElts() = lhsExprList
    ) and
    // 处理右侧为元组或列表的情况
    (
      (
        assignment.getValue().(Tuple).getElts() = rhsExprList and 
        sequenceType = "tuple"
      ) or
      (
        assignment.getValue().(List).getElts() = rhsExprList and 
        sequenceType = "list"
      )
    ) and
    // 获取位置信息并计算元素数量
    location = assignment.getValue().getLocation() and
    lhsCount = exprListLength(lhsExprList) and
    rhsCount = exprListLength(rhsExprList) and
    // 验证数量不匹配且无星号表达式
    lhsCount != rhsCount and
    not exists(Starred s | 
      lhsExprList.getAnItem() = s or 
      rhsExprList.getAnItem() = s
    )
  )
}

// 检查间接通过元组值解包时的元素数量不匹配情况
predicate indirectUnpackMismatch(Assign assignment, int lhsCount, int rhsCount, Location location) {
  exists(ExprList lhsExprList, TupleValue rhsTupleValue, AstNode origin |
    // 处理左侧为元组或列表的情况
    (
      assignment.getATarget().(Tuple).getElts() = lhsExprList or
      assignment.getATarget().(List).getElts() = lhsExprList
    ) and
    // 处理右侧指向元组值的情况
    assignment.getValue().pointsTo(rhsTupleValue, origin) and
    // 获取位置信息并计算元素数量
    location = origin.getLocation() and
    lhsCount = exprListLength(lhsExprList) and
    rhsCount = rhsTupleValue.length() and
    // 验证数量不匹配且左侧无星号表达式
    lhsCount != rhsCount and
    not lhsExprList.getAnItem() instanceof Starred
  )
}

// 查询所有存在元素数量不匹配的赋值语句
from Assign assignment, int lhsCount, int rhsCount, Location location, string sequenceType
where
  // 检查直接解包或间接解包的不匹配情况
  directUnpackMismatch(assignment, lhsCount, rhsCount, location, sequenceType)
  or
  (
    indirectUnpackMismatch(assignment, lhsCount, rhsCount, location) and
    sequenceType = "tuple"
  )
select assignment,
  // 生成问题描述信息
  "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
  location, sequenceType