/**
 * @name Iterable can be either a string or a sequence
 * @description Iteration over either a string or a sequence in the same loop can cause errors that are hard to find.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       non-local
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iteration-string-and-sequence
 */

import python  // 导入Python库，用于分析Python代码
import semmle.python.filters.Tests  // 导入测试过滤器，用于排除测试代码中的问题

// 定义一个谓词函数，判断给定的值是否为字符串类型
predicate has_string_type(Value v) {
  v.getClass() = ClassValue::str()  // 如果值的类是str
  or
  v.getClass() = ClassValue::unicode() and major_version() = 2  // 或者在Python 2中值为unicode
}

from
  For loop, ControlFlowNode iter, Value str, Value seq, ControlFlowNode seq_origin,
  ControlFlowNode str_origin  // 从循环、控制流节点、字符串值、序列值及其来源节点中选择数据
where
  loop.getIter().getAFlowNode() = iter and  // 获取循环的迭代器节点
  iter.pointsTo(str, str_origin) and  // 迭代器指向字符串值及其来源节点
  iter.pointsTo(seq, seq_origin) and  // 迭代器指向序列值及其来源节点
  has_string_type(str) and  // 判断字符串值是否为字符串类型
  seq.getClass().isIterable() and  // 判断序列值是否为可迭代对象
  not has_string_type(seq) and  // 确保序列值不是字符串类型
  // suppress occurrences from tests  // 抑制来自测试代码的出现
  not seq_origin.getScope().getScope*() instanceof TestScope and  // 排除序列值来源节点在测试范围内的情况
  not str_origin.getScope().getScope*() instanceof TestScope  // 排除字符串值来源节点在测试范围内的情况
select loop,
  "Iteration over $@, of class " + seq.getClass().getName() + ", may also iterate over $@.",
  seq_origin, "sequence", str_origin, "string"  // 选择并报告问题：循环可能同时迭代序列和字符串
