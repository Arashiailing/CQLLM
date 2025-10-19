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
private int len(ExprList el) { result = count(el.getAnItem()) }

// 判断赋值语句中左侧和右侧元素数量是否不匹配
predicate mismatched(Assign a, int lcount, int rcount, Location loc, string sequenceType) {
  exists(ExprList l, ExprList r |
    (
      // 检查赋值目标是否为元组或列表，并获取其元素列表
      a.getATarget().(Tuple).getElts() = l or
      a.getATarget().(List).getElts() = l
    ) and
    (
      // 检查赋值值是否为元组或列表，并获取其元素列表
      a.getValue().(Tuple).getElts() = r and sequenceType = "tuple"
      or
      a.getValue().(List).getElts() = r and sequenceType = "list"
    ) and
    // 获取赋值位置
    loc = a.getValue().getLocation() and
    // 计算左侧和右侧元素的数量
    lcount = len(l) and
    rcount = len(r) and
    // 检查左右侧元素数量是否不匹配
    lcount != rcount and
    // 确保没有使用星号表达式（*）
    not exists(Starred s | l.getAnItem() = s or r.getAnItem() = s)
  )
}

// 判断赋值语句中右侧为元组时的元素数量是否不匹配
predicate mismatched_tuple_rhs(Assign a, int lcount, int rcount, Location loc) {
  exists(ExprList l, TupleValue r, AstNode origin |
    (
      // 检查赋值目标是否为元组或列表，并获取其元素列表
      a.getATarget().(Tuple).getElts() = l or
      a.getATarget().(List).getElts() = l
    ) and
    // 检查赋值值是否指向一个元组值
    a.getValue().pointsTo(r, origin) and
    // 获取赋值位置
    loc = origin.getLocation() and
    // 计算左侧和右侧元素的数量
    lcount = len(l) and
    rcount = r.length() and
    // 检查左右侧元素数量是否不匹配
    lcount != rcount and
    // 确保左侧没有使用星号表达式（*）
    not l.getAnItem() instanceof Starred
  )
}

// 查询所有存在元素数量不匹配的赋值语句
from Assign a, int lcount, int rcount, Location loc, string sequenceType
where
  // 检查是否存在元素数量不匹配的情况
  mismatched(a, lcount, rcount, loc, sequenceType)
  or
  mismatched_tuple_rhs(a, lcount, rcount, loc) and
  sequenceType = "tuple"
select a,
  // 生成问题描述信息
  "Left hand side of assignment contains " + lcount +
    " variables, but right hand side is a $@ of length " + rcount + ".", loc, sequenceType
