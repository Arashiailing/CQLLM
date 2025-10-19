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

// 计算表达式列表中元素的数量
private int exprListLength(ExprList exprs) { 
  result = count(exprs.getAnItem()) 
}

// 检测显式序列赋值中的元素数量不匹配
predicate explicitSequenceMismatch(Assign assign, int lhsSize, int rhsSize, Location loc, string seqType) {
  exists(ExprList lhsExprs, ExprList rhsExprs |
    // 验证赋值目标为元组或列表
    (assign.getATarget().(Tuple).getElts() = lhsExprs or 
     assign.getATarget().(List).getElts() = lhsExprs) and
    // 验证赋值源为元组或列表
    (assign.getValue().(Tuple).getElts() = rhsExprs and seqType = "tuple" or
     assign.getValue().(List).getElts() = rhsExprs and seqType = "list") and
    // 获取赋值位置
    loc = assign.getValue().getLocation() and
    // 计算左右两侧元素数量
    lhsSize = exprListLength(lhsExprs) and
    rhsSize = exprListLength(rhsExprs) and
    // 确认元素数量不匹配
    lhsSize != rhsSize and
    // 排除星号表达式情况
    not exists(Starred s | lhsExprs.getAnItem() = s or rhsExprs.getAnItem() = s)
  )
}

// 检测元组值引用赋值中的元素数量不匹配
predicate tupleValueMismatch(Assign assign, int lhsSize, int rhsSize, Location loc) {
  exists(ExprList lhsExprs, TupleValue rhsTuple, AstNode originNode |
    // 验证赋值目标为元组或列表
    (assign.getATarget().(Tuple).getElts() = lhsExprs or 
     assign.getATarget().(List).getElts() = lhsExprs) and
    // 验证赋值源指向元组值
    assign.getValue().pointsTo(rhsTuple, originNode) and
    // 获取赋值位置
    loc = originNode.getLocation() and
    // 计算左右两侧元素数量
    lhsSize = exprListLength(lhsExprs) and
    rhsSize = rhsTuple.length() and
    // 确认元素数量不匹配
    lhsSize != rhsSize and
    // 排除左侧星号表达式情况
    not lhsExprs.getAnItem() instanceof Starred
  )
}

// 查询所有存在元素数量不匹配的赋值语句
from Assign assign, int lhsSize, int rhsSize, Location loc, string seqType
where
  // 检查显式序列赋值不匹配
  explicitSequenceMismatch(assign, lhsSize, rhsSize, loc, seqType)
  or
  // 检查元组值引用赋值不匹配（强制序列类型为元组）
  tupleValueMismatch(assign, lhsSize, rhsSize, loc) and 
  seqType = "tuple"
select assign,
  // 生成问题描述信息
  "Left hand side of assignment contains " + lhsSize +
    " variables, but right hand side is a $@ of length " + rhsSize + ".", loc, seqType