/**
 * 评估函数调用图在不同上下文深度下的扩展特性，分析调用关系的分布模式与性能特征。
 * 通过对比去重调用与全上下文调用的数量，计算调用图分析的效率指标，以量化分析开销。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：unique_call_count（去重调用数）、full_context_calls（全上下文调用总数）、
// context_depth（调用上下文深度）和call_efficiency（调用效率比率）
from int unique_call_count, int full_context_calls, int context_depth, float call_efficiency
where
  // 第一部分：计算在特定深度下的去重调用数量
  unique_call_count =
    strictcount(ControlFlowNode call_site, CallableValue target_function |
      exists(PointsToContext current_context |
        // 获取函数调用并记录其上下文深度
        call_site = target_function.getACall(current_context) and
        context_depth = current_context.getDepth() and
        // 确保该调用在更浅上下文中不存在
        not exists(PointsToContext shallow_context |
          call_site = target_function.getACall(shallow_context) and
          shallow_context.getDepth() < context_depth
        )
      )
    ) and

  // 第二部分：计算在相同深度下的全上下文调用总数
  full_context_calls =
    strictcount(ControlFlowNode call_site, CallableValue target_function, PointsToContext current_context |
      // 获取函数调用并验证上下文深度匹配
      call_site = target_function.getACall(current_context) and
      context_depth = current_context.getDepth()
    ) and

  // 第三部分：计算调用效率比率
  call_efficiency = 100.0 * unique_call_count / full_context_calls
select context_depth, unique_call_count, full_context_calls, call_efficiency // 输出调用深度及相应的调用统计信息