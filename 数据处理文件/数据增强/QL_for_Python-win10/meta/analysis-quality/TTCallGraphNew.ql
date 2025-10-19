/**
 * @name 使用类型跟踪而不是指向分析的新调用图边
 * @kind 问题
 * @problem.severity 建议
 * @id py/meta/call-graph-new
 * @precision 非常低
 */

import python
import CallGraphQuality

// 从CallNode和Target中选择调用节点和目标节点
from CallNode call, Target target
where
  // 目标节点是相关的
  target.isRelevant() and
  // 并且调用节点的基于指向分析的可解析调用的目标不等于目标节点，且调用节点的基于类型跟踪的可解析调用的目标等于目标节点
  not call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and
  call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target
select call, "NEW: $@ to $@", call, "Call", target, target.toString()
