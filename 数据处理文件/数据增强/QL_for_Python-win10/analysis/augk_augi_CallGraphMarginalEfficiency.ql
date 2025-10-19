/**
 * 评估调用图在不同上下文深度下的性能效率。
 * 本查询计算三个关键指标：
 * 1. 特定深度下的唯一调用节点数量（表示边际增长）
 * 2. 该深度及以下的调用节点累计总数（表示整体规模）
 * 3. 唯一调用数与总调用数的比率（效率衡量标准）
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：distinct_calls（唯一调用数）、cumulative_calls（累计调用数）、depth_level（上下文深度）和efficiency_metric（效率指标）
from int distinct_calls, int cumulative_calls, int depth_level, float efficiency_metric
where
  // 计算在特定深度下的唯一调用节点数量
  distinct_calls =
    strictcount(ControlFlowNode node, CallableValue target |
      exists(PointsToContext context |
        node = target.getACall(context) and // 获取可调用对象在特定上下文中的调用节点
        depth_level = context.getDepth() and // 获取当前上下文深度
        not exists(PointsToContext shallow_ctx |
          node = target.getACall(shallow_ctx) and // 确保没有更浅上下文包含相同调用节点
          shallow_ctx.getDepth() < depth_level
        )
      )
    ) and
  // 计算在特定深度及以下的所有调用节点总数
  cumulative_calls =
    strictcount(ControlFlowNode node, CallableValue target, PointsToContext context |
      node = target.getACall(context) and // 获取可调用对象在任意上下文中的调用节点
      depth_level = context.getDepth() // 记录上下文深度
    ) and
  // 计算调用效率指标，即唯一调用数与总调用数的百分比
  efficiency_metric = 100.0 * distinct_calls / cumulative_calls
select depth_level, distinct_calls, cumulative_calls, efficiency_metric // 输出结果字段