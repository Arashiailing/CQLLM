/**
 * @name Shared call graph edge from using type-tracking instead of points-to
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph-shared
 * @precision very-low
 */

import python // 导入python库，用于分析Python代码
import CallGraphQuality // 导入CallGraphQuality库，用于调用图质量分析

// 从CallNode和Target中选择数据
from CallNode call, Target target
where
  target.isRelevant() and // 目标节点是相关的
  call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and // 基于指向的调用图中的可解析调用的目标等于目标节点
  call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target // 基于类型跟踪的调用图中的可解析调用的目标也等于目标节点
select call, "SHARED: $@ to $@", call, "Call", target, target.toString() // 选择调用节点并格式化输出信息，表示共享的调用图边
