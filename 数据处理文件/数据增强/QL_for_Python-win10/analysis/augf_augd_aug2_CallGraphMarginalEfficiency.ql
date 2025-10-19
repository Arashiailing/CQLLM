/**
 * 分析调用图在不同上下文深度下的边际增长特性，评估调用关系的规模分布与计算效率。
 * 通过比较唯一调用与全上下文调用的数量差异，量化调用图分析的效率比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：unique_call_count（唯一调用数）、full_context_calls（全上下文调用数）、
// context_depth（上下文深度）和call_efficiency（调用效率）
from int unique_call_count, int full_context_calls, int context_depth, float call_efficiency
where
  // 第一部分：计算在指定深度下的唯一调用数（排除更浅上下文中的重复调用）
  unique_call_count =
    strictcount(ControlFlowNode invocation_node, CallableValue called_function |
      exists(PointsToContext active_context |
        // 获取函数调用并记录上下文深度
        invocation_node = called_function.getACall(active_context) and
        context_depth = active_context.getDepth() and
        // 确保没有在更浅上下文中存在相同调用
        not exists(PointsToContext less_deep_context |
          invocation_node = called_function.getACall(less_deep_context) and
          less_deep_context.getDepth() < context_depth
        )
      )
    ) and

  // 第二部分：计算在指定深度下的全上下文调用总数（包括所有上下文中的调用）
  full_context_calls =
    strictcount(ControlFlowNode invocation_node, CallableValue called_function, PointsToContext active_context |
      // 获取函数调用并确保上下文深度一致
      invocation_node = called_function.getACall(active_context) and
      context_depth = active_context.getDepth()
    ) and

  // 第三部分：计算调用效率比率
  call_efficiency = 100.0 * unique_call_count / full_context_calls
select context_depth, unique_call_count, full_context_calls, call_efficiency // 输出上下文深度及对应的调用统计信息