/**
 * 分析调用图在不同上下文深度下的扩展特性，评估调用关系的分布模式与计算性能。
 * 本查询通过比较去重调用与全上下文调用的数量，计算调用图分析的效率指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：unique_call_count（去重调用数）、full_context_calls（全上下文调用数）、
// context_depth（上下文深度）和call_efficiency（调用效率）
from int unique_call_count, int full_context_calls, int context_depth, float call_efficiency
where
  // 计算在指定深度下的去重调用数（排除在更浅上下文中已存在的相同调用）
  unique_call_count =
    strictcount(ControlFlowNode call_site, CallableValue called_function |
      exists(PointsToContext context |
        call_site = called_function.getACall(context) and // 获取函数在特定上下文中的调用点
        context_depth = context.getDepth() and // 记录当前上下文深度
        // 确保在更浅上下文中不存在相同调用
        not exists(PointsToContext shallow_context |
          call_site = called_function.getACall(shallow_context) and
          shallow_context.getDepth() < context_depth
        )
      )
    ) and

  // 计算在指定深度下的全上下文调用总数（包括所有上下文中的调用）
  full_context_calls =
    strictcount(ControlFlowNode call_site, CallableValue called_function, PointsToContext context |
      call_site = called_function.getACall(context) and // 获取函数在任意上下文中的调用点
      context_depth = context.getDepth() // 确保上下文深度一致
    ) and

  // 计算调用效率：去重调用数占总调用数的百分比
  call_efficiency = 100.0 * unique_call_count / full_context_calls
select context_depth, unique_call_count, full_context_calls, call_efficiency // 输出上下文深度及对应的调用统计信息