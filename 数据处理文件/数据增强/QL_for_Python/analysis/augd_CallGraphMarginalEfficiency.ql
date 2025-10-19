/**
 * 分析调用图在不同上下文深度下的边际增长特性。
 * 此查询计算三个关键指标：
 * 1. 边际事实数：在特定深度下首次出现的调用节点数量
 * 2. 总体规模：在该深度下的所有调用节点数量
 * 3. 效率比率：边际事实数与总体规模的百分比，表示新增调用节点的比例
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量
from int marginal_facts, int overall_size, int context_depth, float efficiency_ratio
where
  // 计算在给定深度下首次出现的调用节点数量（边际事实数）
  marginal_facts =
    strictcount(ControlFlowNode call, CallableValue func |
      exists(PointsToContext ctx |
        // 调用节点在指定深度下存在
        call = func.getACall(ctx) and
        context_depth = ctx.getDepth() and
        // 调用节点在更浅的深度下不存在
        not exists(PointsToContext shallower |
          call = func.getACall(shallower) and
          shallower.getDepth() < context_depth
        )
      )
    ) and
  // 计算在给定深度下的所有调用节点数量（总体规模）
  overall_size =
    strictcount(ControlFlowNode call, CallableValue func, PointsToContext ctx |
      call = func.getACall(ctx) and
      context_depth = ctx.getDepth()
    ) and
  // 计算效率比率：边际事实数与总体规模的百分比
  efficiency_ratio = 100.0 * marginal_facts / overall_size
select context_depth, marginal_facts, overall_size, efficiency_ratio