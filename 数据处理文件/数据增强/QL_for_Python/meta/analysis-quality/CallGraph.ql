/**
 * @name Call graph
 * @description An edge in the call graph.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// 导入Python语言库
import python
// 导入数据流分析相关的内部库
import semmle.python.dataflow.new.internal.DataFlowPrivate
// 导入元度量相关的库
import meta.MetaMetrics

// 从数据流调用和可调用目标中选择边
from DataFlowCall call, DataFlowCallable target
where
  // 目标必须是可行的可调用对象
  target = viableCallable(call) and
  // 排除忽略文件中的调用位置
  not call.getLocation().getFile() instanceof IgnoredFile and
  // 排除忽略文件中的目标作用域位置
  not target.getScope().getLocation().getFile() instanceof IgnoredFile
select call, "Call to $@", target.getScope(), target.toString()
