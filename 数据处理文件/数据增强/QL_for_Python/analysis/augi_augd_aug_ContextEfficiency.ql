/**
 * 分析指向关系压缩效率：计算唯一事实数量与关系总数，
 * 并评估在不同上下文深度下的压缩比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总数、上下文深度和压缩比率
from int distinct_facts_num, int total_relations_count, int context_depth, float compression_ratio
where
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 类对象)组合
  distinct_facts_num =
    strictcount(ControlFlowNode control_node, Object target_object, ClassObject class_object |
      exists(PointsToContext ctx |
        // 检查在给定上下文中，控制流节点指向目标对象，且该对象是类对象的实例
        PointsTo::points_to(control_node, ctx, target_object, class_object, _) and
        context_depth = ctx.getDepth()
      )
    ) and
  // 计算关系总数：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源节点)组合
  total_relations_count =
    strictcount(ControlFlowNode control_node, Object target_object, ClassObject class_object, 
      PointsToContext ctx, ControlFlowNode source_node |
      // 检查在给定上下文中，控制流节点指向目标对象，且该对象是类对象的实例，并记录源节点
      PointsTo::points_to(control_node, ctx, target_object, class_object, source_node) and
      context_depth = ctx.getDepth()
    ) and
  // 计算压缩比率：唯一事实数量与关系总数的百分比
  total_relations_count > 0 and
  compression_ratio = 100.0 * distinct_facts_num / total_relations_count
// 输出结果：上下文深度、唯一事实数量、关系总数和压缩比率
select context_depth, distinct_facts_num, total_relations_count, compression_ratio