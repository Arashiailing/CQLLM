/**
 * 分析指向关系的压缩效率：统计唯一事实数量、关系总大小，
 * 并计算它们相对于上下文深度的压缩比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩比率
from int fact_count, int relation_size, int context_depth, float compression_ratio
where
  // 计算唯一事实数量：统计不同的(控制流节点, 对象, 类对象)组合
  fact_count =
    strictcount(ControlFlowNode node, Object obj, ClassObject classObj |
      exists(PointsToContext context |
        // 检查在给定上下文中，节点是否指向对象，且该对象是类对象的实例
        PointsTo::points_to(node, context, obj, classObj, _) and
        context_depth = context.getDepth()
      )
    ) and
  // 计算关系总大小：统计所有(控制流节点, 对象, 类对象, 上下文, 源节点)组合
  relation_size =
    strictcount(ControlFlowNode node, Object obj, ClassObject classObj, 
      PointsToContext context, ControlFlowNode sourceNode |
      // 检查在给定上下文中，节点是否指向对象，且该对象是类对象的实例，并记录源节点
      PointsTo::points_to(node, context, obj, classObj, sourceNode) and
      context_depth = context.getDepth()
    ) and
  // 计算压缩比率：唯一事实数量与关系总大小的百分比
  compression_ratio = 100.0 * fact_count / relation_size
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩比率
select context_depth, fact_count, relation_size, compression_ratio