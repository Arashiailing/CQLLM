/**
 * 评估指向关系图的压缩效率：计算唯一事实的数量、关系图的总大小，
 * 以及它们相对于上下文深度的压缩效率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩效率
from int unique_facts_count, int total_relations_size, int ctx_depth, float compression_efficiency
where
  // 首先确定上下文深度
  exists(PointsToContext ctx | ctx_depth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同的(控制流节点, 被指向对象, 类对象)组合
  unique_facts_count =
    strictcount(ControlFlowNode cfg_node, Object pointed_obj, ClassObject cls_obj |
      exists(PointsToContext ctx |
        // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例
        PointsTo::points_to(cfg_node, ctx, pointed_obj, cls_obj, _) and
        ctx.getDepth() = ctx_depth
      )
    ) and
  // 计算关系总大小：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)组合
  total_relations_size =
    strictcount(ControlFlowNode cfg_node, Object pointed_obj, ClassObject cls_obj, 
      PointsToContext ctx, ControlFlowNode source_cfg_node |
      // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(cfg_node, ctx, pointed_obj, cls_obj, source_cfg_node) and
      ctx.getDepth() = ctx_depth
    ) and
  // 计算压缩效率：唯一事实数量与关系总大小的百分比
  compression_efficiency = 100.0 * unique_facts_count / total_relations_size
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩效率
select ctx_depth, unique_facts_count, total_relations_size, compression_efficiency