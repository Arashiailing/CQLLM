/**
 * 分析调用图在不同上下文深度下的效率指标。
 * 该查询计算：
 * 1. 在特定深度下的唯一调用节点数量（边际增加的事实）
 * 2. 在该深度及以下的所有调用节点总数（总体大小）
 * 3. 唯一调用数与总调用数的比例（效率指标）
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：unique_calls（唯一调用数）、all_calls（所有调用数）、context_depth（上下文深度）和call_efficiency（调用效率）
from int unique_calls, int all_calls, int context_depth, float call_efficiency
where
  // 计算在给定深度下的唯一调用节点数量
  unique_calls =
    strictcount(ControlFlowNode call, CallableValue func |
      exists(PointsToContext ctx |
        call = func.getACall(ctx) and // 获取函数在特定上下文中的调用节点
        context_depth = ctx.getDepth() and // 获取上下文的深度
        not exists(PointsToContext shallower |
          call = func.getACall(shallower) and // 确保没有更浅的上下文包含相同的调用节点
          shallower.getDepth() < context_depth
        )
      )
    ) and
  // 计算在给定深度及以下的所有调用节点总数
  all_calls =
    strictcount(ControlFlowNode call, CallableValue func, PointsToContext ctx |
      call = func.getACall(ctx) and // 获取函数在任意上下文中的调用节点
      context_depth = ctx.getDepth() // 获取上下文的深度
    ) and
  // 计算调用效率，即唯一调用数与所有调用数的百分比
  call_efficiency = 100.0 * unique_calls / all_calls
select context_depth, unique_calls, all_calls, call_efficiency // 选择要显示的结果字段