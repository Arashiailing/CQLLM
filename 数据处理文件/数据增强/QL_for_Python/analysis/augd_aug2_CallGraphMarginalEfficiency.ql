/**
 * 评估调用图在不同上下文深度下的边际增长特性，分析调用关系的规模分布与计算效率。
 * 该查询通过比较唯一调用与全上下文调用的数量，量化调用图分析的效率比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：distinct_call_count（唯一调用数）、total_contextual_calls（全上下文调用数）、
// invocation_depth（上下文深度）和efficiency_ratio（调用效率）
from int distinct_call_count, int total_contextual_calls, int invocation_depth, float efficiency_ratio
where
  // 计算在指定深度下的唯一调用数（排除更浅上下文中的重复调用）
  distinct_call_count =
    strictcount(ControlFlowNode call_node, CallableValue target_func |
      exists(PointsToContext current_ctx |
        call_node = target_func.getACall(current_ctx) and // 获取函数在特定上下文中的调用节点
        invocation_depth = current_ctx.getDepth() and // 记录当前上下文深度
        // 确保没有在更浅上下文中存在相同调用
        not exists(PointsToContext shallower_ctx |
          call_node = target_func.getACall(shallower_ctx) and
          shallower_ctx.getDepth() < invocation_depth
        )
      )
    ) and

  // 计算在指定深度下的全上下文调用总数（包括所有上下文中的调用）
  total_contextual_calls =
    strictcount(ControlFlowNode call_node, CallableValue target_func, PointsToContext current_ctx |
      call_node = target_func.getACall(current_ctx) and // 获取函数在任意上下文中的调用节点
      invocation_depth = current_ctx.getDepth() // 确保上下文深度一致
    ) and

  // 计算调用效率：唯一调用数占总调用数的百分比
  efficiency_ratio = 100.0 * distinct_call_count / total_contextual_calls
select invocation_depth, distinct_call_count, total_contextual_calls, efficiency_ratio // 输出上下文深度及对应的调用统计信息