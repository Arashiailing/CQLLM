/**
 * 分析指向关系图的压缩性能指标：统计不同事实的数量、关系图的整体规模，
 * 以及基于上下文深度的压缩比率计算。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：不同事实数量、关系总规模、上下文深度和压缩比率
from int distinct_facts_num, int relations_total_size, int context_depth, float efficiency_ratio
where
  // 获取当前分析的上下文深度
  exists(PointsToContext ctx | context_depth = ctx.getDepth()) and
  // 统计不同事实的数量：计算唯一的(控制流节点, 目标对象, 类类型)三元组
  distinct_facts_num =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_type |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且目标对象是类类型的实例
        PointsTo::points_to(flow_node, ctx, target_object, class_type, _) and
        ctx.getDepth() = context_depth
      )
    ) and
  // 计算关系的总体规模：统计所有(控制流节点, 目标对象, 类类型, 上下文, 源控制流节点)五元组
  relations_total_size =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_type, 
      PointsToContext ctx, ControlFlowNode source_flow_node |
      // 验证在指定上下文中，控制流节点指向目标对象，且目标对象是类类型的实例，同时记录源控制流节点
      PointsTo::points_to(flow_node, ctx, target_object, class_type, source_flow_node) and
      ctx.getDepth() = context_depth
    ) and
  // 计算压缩比率：不同事实数量占关系总规模的百分比
  efficiency_ratio = 100.0 * distinct_facts_num / relations_total_size
// 输出分析结果：上下文深度、不同事实数量、关系总规模和压缩比率
select context_depth, distinct_facts_num, relations_total_size, efficiency_ratio