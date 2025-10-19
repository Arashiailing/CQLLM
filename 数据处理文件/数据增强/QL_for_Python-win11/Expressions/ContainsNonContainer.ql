/**
 * @name Membership test with a non-container
 * @description A membership test, such as 'item in sequence', with a non-container on the right hand side will raise a 'TypeError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/member-test-non-container
 */

import python  // 导入python库，用于处理Python代码的解析和分析
import semmle.python.pointsto.PointsTo  // 导入semmle.python.pointsto.PointsTo库，用于指向集分析

// 定义一个谓词函数rhs_in_expr，用于判断Compare对象中是否包含In或NotIn操作符
predicate rhs_in_expr(ControlFlowNode rhs, Compare cmp) {
  exists(Cmpop op, int i | cmp.getOp(i) = op and cmp.getComparator(i) = rhs.getNode() |
    op instanceof In or op instanceof NotIn  // 如果存在In或NotIn操作符，则返回true
  )
}

// 从ControlFlowNode、Compare、Value、ClassValue和ControlFlowNode类型的变量中选择数据
from ControlFlowNode non_seq, Compare cmp, Value v, ClassValue cls, ControlFlowNode origin
where
  rhs_in_expr(non_seq, cmp) and  // 条件1：右侧表达式是In或NotIn操作符
  non_seq.pointsTo(_, v, origin) and  // 条件2：non_seq节点指向某个值v，并且origin是该指向的起点
  v.getClass() = cls and  // 条件3：值v的类为cls
  not Types::failedInference(cls, _) and  // 条件4：没有对cls的类型推断失败
  not cls.hasAttribute("__contains__") and  // 条件5：cls类没有__contains__属性
  not cls.hasAttribute("__iter__") and  // 条件6：cls类没有__iter__属性
  not cls.hasAttribute("__getitem__") and  // 条件7：cls类没有__getitem__属性
  not cls = ClassValue::nonetype() and  // 条件8：cls不是None类型
  not cls = Value::named("types.MappingProxyType")  // 条件9：cls不是types.MappingProxyType类型
select cmp, "This test may raise an Exception as the $@ may be of non-container class $@.", origin,
  "target", cls, cls.getName()  // 选择符合条件的Compare对象cmp，并报告可能引发异常的情况，包括origin节点和目标类cls及其名称
