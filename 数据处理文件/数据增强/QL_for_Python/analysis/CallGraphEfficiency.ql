/**
 * 计算调用图的总事实数、调用图关系的总大小以及两者相对于上下文深度的比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：total_facts（总事实数）、total_size（总大小）、depth（深度）和efficiency（效率）
from int total_facts, int total_size, int depth, float efficiency
where
  // 计算调用图中的总事实数，即满足条件的ControlFlowNode和CallableValue对的数量
  total_facts =
    strictcount(ControlFlowNode call, CallableValue func |
      exists(PointsToContext ctx |
        call = func.getACall(ctx) and // 获取函数func在上下文ctx中的调用节点call
        depth = ctx.getDepth() // 获取上下文ctx的深度
      )
    ) and
  // 计算调用图关系的总大小，即满足条件的ControlFlowNode、CallableValue和PointsToContext三元组的数量
  total_size =
    strictcount(ControlFlowNode call, CallableValue func, PointsToContext ctx |
      call = func.getACall(ctx) and // 获取函数func在上下文ctx中的调用节点call
      depth = ctx.getDepth() // 获取上下文ctx的深度
    ) and
  // 计算效率，即总事实数与总大小的比率，并转换为百分比形式
  efficiency = 100.0 * total_facts / total_size
select depth, total_facts, total_size, efficiency // 选择要返回的结果字段：深度、总事实数、总大小和效率
