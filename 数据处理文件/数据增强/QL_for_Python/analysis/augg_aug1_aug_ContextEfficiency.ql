/**
 * 分析指向关系图的压缩性能：测量不同上下文深度下的唯一事实数量、
 * 整个关系图的规模，以及相应的压缩比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系图总规模、上下文深度和压缩比率
from int distinct_facts_count, int total_graph_size, int context_depth, float compression_ratio
where
  // 确定当前分析的上下文深度
  exists(PointsToContext ctx | context_depth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 类类型)组合
  distinct_facts_count =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_type |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类类型的实例
        PointsTo::points_to(flow_node, ctx, target_object, class_type, _) and
        ctx.getDepth() = context_depth
      )
    ) and
  // 计算关系图总规模：统计所有(控制流节点, 目标对象, 类类型, 上下文, 源控制流节点)组合
  total_graph_size =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_type, 
      PointsToContext ctx, ControlFlowNode source_flow_node |
      // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类类型的实例，并记录源控制流节点
      PointsTo::points_to(flow_node, ctx, target_object, class_type, source_flow_node) and
      ctx.getDepth() = context_depth
    ) and
  // 计算压缩比率：唯一事实数量与关系图总规模的百分比
  compression_ratio = 100.0 * distinct_facts_count / total_graph_size
// 输出结果：上下文深度、唯一事实数量、关系图总规模和压缩比率
select context_depth, distinct_facts_count, total_graph_size, compression_ratio