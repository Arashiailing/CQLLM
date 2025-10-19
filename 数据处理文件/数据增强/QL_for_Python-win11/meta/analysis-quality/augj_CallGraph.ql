/**
 * @name Call graph edge
 * @description Represents an edge in the call graph, showing a function call and its target.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// 导入Python语言核心库
import python
// 导入用于数据流分析的内部模块
import semmle.python.dataflow.new.internal.DataFlowPrivate
// 导入元度量计算相关的库
import meta.MetaMetrics

// 从数据流调用和可调用目标中选择边
from DataFlowCall invocation, DataFlowCallable callableTarget
where
  // 目标必须是可行的可调用对象
  (callableTarget = viableCallable(invocation)) and
  // 排除忽略文件中的调用位置
  (not invocation.getLocation().getFile() instanceof IgnoredFile) and
  // 排除忽略文件中的目标作用域位置
  (not callableTarget.getScope().getLocation().getFile() instanceof IgnoredFile)
select invocation, "Call to $@", callableTarget.getScope(), callableTarget.toString()