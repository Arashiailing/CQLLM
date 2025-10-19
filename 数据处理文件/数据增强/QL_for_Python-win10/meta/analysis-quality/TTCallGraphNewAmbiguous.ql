/**
 * @name New call graph edge from using type-tracking instead of points-to, that is ambiguous
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph-new-ambiguous
 * @precision very-low
 */

// 导入python模块
import python
// 导入CallGraphQuality模块
import CallGraphQuality

// 从CallNode和Target中选择数据
from CallNode call, Target target
where
  // 目标节点是相关的
  target.isRelevant() and
  // 使用PointsToBasedCallGraph解析的目标不等于当前目标
  not call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and
  // 使用TypeTrackingBasedCallGraph解析的目标等于当前目标
  call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target and
  // 使用TypeTrackingBasedCallGraph解析的目标数量大于1，表示存在歧义
  1 < count(call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget())
select call, "NEW: $@ to $@", call, "Call", target, target.toString()
