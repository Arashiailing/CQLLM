/**
 * 评估指向关系压缩效率：量化唯一事实数量与关系总规模，
 * 并分析它们相对于上下文深度的压缩效率指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、关系总规模、上下文深度和压缩效率
from int unique_facts_count, int total_relations_size, int ctx_depth, float compression_efficiency
where
  // 计算唯一事实计数：统计不同的(控制流节点, 目标对象, 类对象)三元组
  unique_facts_count =
    strictcount(ControlFlowNode cfg_node, Object target_obj, ClassObject cls_obj |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类对象的实例
        PointsTo::points_to(cfg_node, ctx, target_obj, cls_obj, _) and
        ctx_depth = ctx.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源节点)五元组
  total_relations_size =
    strictcount(ControlFlowNode cfg_node, Object target_obj, ClassObject cls_obj, 
      PointsToContext ctx, ControlFlowNode origin_node |
      // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类对象的实例，并记录源节点
      PointsTo::points_to(cfg_node, ctx, target_obj, cls_obj, origin_node) and
      ctx_depth = ctx.getDepth()
    ) and
  // 计算压缩效率：唯一事实计数与关系总规模的百分比
  compression_efficiency = 100.0 * unique_facts_count / total_relations_size
// 输出结果：上下文深度、唯一事实计数、关系总规模和压缩效率
select ctx_depth, unique_facts_count, total_relations_size, compression_efficiency