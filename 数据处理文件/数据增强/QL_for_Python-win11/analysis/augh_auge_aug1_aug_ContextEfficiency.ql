/**
 * 评估指向关系图的压缩效率：计算唯一事实的计数、关系图的总体大小，
 * 以及根据上下文深度得出的压缩效率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：唯一事实计数、关系图总大小、上下文深度和压缩效率
from int unique_facts_count, int graph_total_size, int ctx_depth, float compression_efficiency
where
  // 获取当前分析的上下文深度
  exists(PointsToContext ctx | ctx_depth = ctx.getDepth()) and
  // 计算唯一事实的数量：统计唯一的(控制流节点, 目标对象, 类类型)组合
  unique_facts_count =
    strictcount(ControlFlowNode flow_node, Object target_obj, ClassObject class_type |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且目标对象是类类型的实例
        PointsTo::points_to(flow_node, ctx, target_obj, class_type, _) and
        ctx.getDepth() = ctx_depth
      )
    ) and
  // 计算关系图的总大小：统计所有(控制流节点, 目标对象, 类类型, 上下文, 源控制流节点)组合
  graph_total_size =
    strictcount(ControlFlowNode flow_node, Object target_obj, ClassObject class_type, 
      PointsToContext ctx, ControlFlowNode source_node |
      // 验证在指定上下文中，控制流节点指向目标对象，且目标对象是类类型的实例，同时记录源控制流节点
      PointsTo::points_to(flow_node, ctx, target_obj, class_type, source_node) and
      ctx.getDepth() = ctx_depth
    ) and
  // 计算压缩效率：唯一事实数量占关系图总大小的百分比
  compression_efficiency = 100.0 * unique_facts_count / graph_total_size
// 输出评估结果：上下文深度、唯一事实计数、关系图总大小和压缩效率
select ctx_depth, unique_facts_count, graph_total_size, compression_efficiency