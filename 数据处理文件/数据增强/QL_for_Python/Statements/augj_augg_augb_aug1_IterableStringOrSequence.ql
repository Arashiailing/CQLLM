/**
 * @name 可迭代对象可能是字符串或序列
 * @description 识别同时迭代字符串和序列类型的循环。
 * 这种迭代模式可能导致运行时错误，因为字符串产生字符而序列产生元素，
 * 从而导致难以调试的不一致行为。
 * @kind problem
 * @tags reliability
 *       maintainability
 *       non-local
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iteration-string-and-sequence
 */

import python
import semmle.python.filters.Tests

// 判断值是否为字符串类型（str 或 Python 2 的 unicode）
predicate isStringType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For targetLoop, 
  ControlFlowNode iterNode, 
  Value strVal, 
  Value seqVal, 
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where 
  // 关联循环与其迭代器表达式
  targetLoop.getIter().getAFlowNode() = iterNode
  
  // 确保迭代器表达式同时指向字符串和序列值
  and iterNode.pointsTo(strVal, strOrigin)
  and iterNode.pointsTo(seqVal, seqOrigin)
  
  // 验证类型约束：一个字符串和一个非字符串可迭代对象
  and isStringType(strVal)
  and seqVal.getClass().isIterable()
  and not isStringType(seqVal)
  
  // 排除测试代码中的节点
  and not seqOrigin.getScope().getScope*() instanceof TestScope
  and not strOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + seqVal.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"