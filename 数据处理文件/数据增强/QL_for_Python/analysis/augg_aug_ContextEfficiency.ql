/**
 * 评估指向关系的压缩效率：通过计算唯一事实数量与关系总大小，
 * 并分析它们相对于上下文深度的压缩比率来评估存储优化效果。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩效率
from int unique_facts, int total_relations, int ctx_depth, float compression_efficiency
where
  // 计算唯一事实数量：统计不同的(控制流节点, 对象, 类对象)组合
  unique_facts =
    strictcount(ControlFlowNode node, Object obj, ClassObject classObj |
      exists(PointsToContext context |
        // 检查在给定上下文中，节点是否指向对象，且该对象是类对象的实例
        PointsTo::points_to(node, context, obj, classObj, _) and
        ctx_depth = context.getDepth()
      )
    ) and
  // 计算关系总大小：统计所有(控制流节点, 对象, 类对象, 上下文, 源节点)组合
  total_relations =
    strictcount(ControlFlowNode node, Object obj, ClassObject classObj, 
      PointsToContext context, ControlFlowNode sourceNode |
      // 检查在给定上下文中，节点是否指向对象，且该对象是类对象的实例，并记录源节点
      PointsTo::points_to(node, context, obj, classObj, sourceNode) and
      ctx_depth = context.getDepth()
    ) and
  // 计算压缩效率：唯一事实数量与关系总大小的百分比
  compression_efficiency = 100.0 * unique_facts / total_relations
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩效率
select ctx_depth, unique_facts, total_relations, compression_efficiency