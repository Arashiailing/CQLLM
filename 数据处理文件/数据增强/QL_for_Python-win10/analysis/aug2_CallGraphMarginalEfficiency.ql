/**
 * 分析调用图的边际事实增长，评估在不同上下文深度下调用关系的总体规模及其效率比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：unique_calls（唯一调用数）、all_context_calls（全上下文调用数）、context_depth（上下文深度）和call_efficiency（调用效率）
from int unique_calls, int all_context_calls, int context_depth, float call_efficiency
where
  // 第一部分：计算唯一调用数
  unique_calls =
    strictcount(ControlFlowNode call, CallableValue func |
      exists(PointsToContext ctx |
        call = func.getACall(ctx) and // 获取函数在特定上下文中的调用节点
        context_depth = ctx.getDepth() and // 获取当前上下文深度
        not exists(PointsToContext shallower |
          call = func.getACall(shallower) and // 确保没有更浅上下文中存在相同调用
          shallower.getDepth() < context_depth
        )
      )
    ) and

  // 第二部分：计算全上下文调用数
  all_context_calls =
    strictcount(ControlFlowNode call, CallableValue func, PointsToContext ctx |
      call = func.getACall(ctx) and // 获取函数在任意上下文中的调用节点
      context_depth = ctx.getDepth() // 获取上下文深度
    ) and

  // 第三部分：计算调用效率
  call_efficiency = 100.0 * unique_calls / all_context_calls
select context_depth, unique_calls, all_context_calls, call_efficiency // 输出结果：上下文深度、唯一调用数、全上下文调用数和调用效率