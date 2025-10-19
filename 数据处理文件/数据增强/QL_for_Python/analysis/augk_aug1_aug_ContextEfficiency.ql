/**
 * 分析指向关系图的压缩性能：测量不同事实的数量、关系图的整体规模，
 * 以及它们相对于上下文深度的压缩比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询输出参数：不同事实数量、关系总规模、上下文深度和压缩比率
from int distinct_facts_num, int relations_total_size, int context_depth, float efficiency_ratio
where
  // 获取上下文深度
  exists(PointsToContext ctx | context_depth = ctx.getDepth()) and
  // 计算不同事实数量：统计唯一的(控制流节点, 目标对象, 类对象)三元组
  distinct_facts_num =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_object |
      exists(PointsToContext ctx |
        // 确认在指定上下文中，控制流节点指向目标对象，且目标对象是类对象的实例
        PointsTo::points_to(flow_node, ctx, target_object, class_object, _) and
        ctx.getDepth() = context_depth
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源控制流节点)五元组
  relations_total_size =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_object, 
      PointsToContext ctx, ControlFlowNode source_flow_node |
      // 确认在指定上下文中，控制流节点指向目标对象，且目标对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(flow_node, ctx, target_object, class_object, source_flow_node) and
      ctx.getDepth() = context_depth
    ) and
  // 计算压缩比率：不同事实数量占关系总规模的百分比
  efficiency_ratio = 100.0 * distinct_facts_num / relations_total_size
// 输出结果：上下文深度、不同事实数量、关系总规模和压缩比率
select context_depth, distinct_facts_num, relations_total_size, efficiency_ratio