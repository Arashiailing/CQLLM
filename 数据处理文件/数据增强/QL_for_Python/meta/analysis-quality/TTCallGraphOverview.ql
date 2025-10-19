/**
 * @name 使用类型跟踪而不是指向集的调用图边概述
 * @id py/meta/call-graph-overview
 * @precision very-low
 */

import python
import CallGraphQuality

// 从字符串标签和整数计数中选择数据
from string tag, int c
where
  // 如果标签是"SHARED"，则计算满足以下条件的调用节点和目标节点的数量：
  // 1. 目标节点是相关的。
  // 2. 在基于指向集的调用图中，调用节点的目标等于目标节点。
  // 3. 在基于类型跟踪的调用图中，调用节点的目标也等于目标节点。
  tag = "SHARED" and
  c =
    count(CallNode call, Target target |
      target.isRelevant() and
      call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and
      call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target
    )
  // 如果标签是"NEW"，则计算满足以下条件的调用节点和目标节点的数量：
  // 1. 目标节点是相关的。
  // 2. 在基于指向集的调用图中，调用节点的目标不等于目标节点。
  // 3. 在基于类型跟踪的调用图中，调用节点的目标等于目标节点。
  or
  tag = "NEW" and
  c =
    count(CallNode call, Target target |
      target.isRelevant() and
      not call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and
      call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target
    )
  // 如果标签是"MISSING"，则计算满足以下条件的调用节点和目标节点的数量：
  // 1. 目标节点是相关的。
  // 2. 在基于指向集的调用图中，调用节点的目标等于目标节点。
  // 3. 在基于类型跟踪的调用图中，调用节点的目标不等于目标节点。
  or
  tag = "MISSING" and
  c =
    count(CallNode call, Target target |
      target.isRelevant() and
      call.(PointsToBasedCallGraph::ResolvableCall).getTarget() = target and
      not call.(TypeTrackingBasedCallGraph::ResolvableCall).getTarget() = target
    )
// 选择标签和计数作为结果输出
select tag, c
