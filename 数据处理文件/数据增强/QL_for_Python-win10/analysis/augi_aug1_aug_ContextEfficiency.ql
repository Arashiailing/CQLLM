/**
 * 分析指向关系图的压缩效率指标：计算不同上下文深度下的唯一事实数量、
 * 关系图的总规模，以及评估压缩效率的比率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总规模、上下文深度和压缩效率比率
from int distinct_facts_count, int total_relations_count, int context_depth, float compression_ratio
where
  // 确定当前分析的上下文深度
  exists(PointsToContext ctx | context_depth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同(控制流节点, 目标对象, 类对象)组合
  distinct_facts_count =
    strictcount(ControlFlowNode control_node, Object target_object, ClassObject class_object |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类对象的实例
        PointsTo::points_to(control_node, ctx, target_object, class_object, _) and
        ctx.getDepth() = context_depth
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源控制流节点)组合
  total_relations_count =
    strictcount(ControlFlowNode control_node, Object target_object, ClassObject class_object, 
      PointsToContext ctx, ControlFlowNode source_node |
      // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类对象的实例，并记录源节点
      PointsTo::points_to(control_node, ctx, target_object, class_object, source_node) and
      ctx.getDepth() = context_depth
    ) and
  // 计算压缩效率比率：唯一事实数量占关系总规模的百分比
  compression_ratio = 100.0 * distinct_facts_count / total_relations_count
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率比率
select context_depth, distinct_facts_count, total_relations_count, compression_ratio