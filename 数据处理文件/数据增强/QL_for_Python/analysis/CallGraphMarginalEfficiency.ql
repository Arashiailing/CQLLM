/**
 * 计算边际增加的调用图事实、调用关系的总体大小以及两者相对于上下文深度的比例。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：total_facts（总事实数）、total_size（总大小）、depth（深度）和efficiency（效率）
from int total_facts, int total_size, int depth, float efficiency
where
  // 计算总事实数，即在给定深度下唯一的调用节点数量
  total_facts =
    strictcount(ControlFlowNode call, CallableValue func |
      exists(PointsToContext ctx |
        call = func.getACall(ctx) and // 获取函数在特定上下文中的调用节点
        depth = ctx.getDepth() and // 获取上下文的深度
        not exists(PointsToContext shallower |
          call = func.getACall(shallower) and // 确保没有更浅的上下文包含相同的调用节点
          shallower.getDepth() < depth
        )
      )
    ) and
  // 计算调用关系的总体大小，即所有上下文中调用节点的数量
  total_size =
    strictcount(ControlFlowNode call, CallableValue func, PointsToContext ctx |
      call = func.getACall(ctx) and // 获取函数在任意上下文中的调用节点
      depth = ctx.getDepth() // 获取上下文的深度
    ) and
  // 计算效率，即总事实数与总大小的比例
  efficiency = 100.0 * total_facts / total_size
select depth, total_facts, total_size, efficiency // 选择要显示的结果字段
