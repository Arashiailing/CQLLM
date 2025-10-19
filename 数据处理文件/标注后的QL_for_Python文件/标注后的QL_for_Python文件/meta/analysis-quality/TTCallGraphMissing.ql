/**
 * @name Missing call graph edge from using type-tracking instead of points-to
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph-missing
 * @precision very-low
 */

// 导入Python库
import python
// 导入调用图质量分析库
import CallGraphQuality

// 从CallNode和Target中选择数据
from CallNode call, Target target
where
  // 目标节点是相关的
  target.isRelevant() and
  // 使用基于指向分析的调用图解析出的目标与当前目标相同
  call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and
  // 使用类型跟踪的调用图未能解析出相同的目标
  not call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target
// 选择符合条件的调用节点和目标节点，并生成警告信息
select call, "MISSING: $@ to $@", call, "Call", target, target.toString()
