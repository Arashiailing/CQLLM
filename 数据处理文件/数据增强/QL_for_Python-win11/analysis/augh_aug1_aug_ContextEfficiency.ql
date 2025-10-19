/**
 * 分析指向关系图的压缩效率：计算唯一事实的数量、关系图的总大小，
 * 以及它们相对于上下文深度的压缩效率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩效率
from int uniqueFactsCount, int totalRelationsSize, int contextDepth, float compressionEfficiency
where
  // 确定上下文深度
  exists(PointsToContext context | contextDepth = context.getDepth()) and
  // 计算唯一事实数量和关系总大小
  (
    // 唯一事实数量：统计不同的(控制流节点, 被指向对象, 类对象)组合
    uniqueFactsCount =
      strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject classObject |
        exists(PointsToContext context |
          // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例
          PointsTo::points_to(controlFlowNode, context, pointedObject, classObject, _) and
          context.getDepth() = contextDepth
        )
      )
    and
    // 关系总大小：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)组合
    totalRelationsSize =
      strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject classObject, 
        PointsToContext context, ControlFlowNode sourceControlFlowNode |
        // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例，并记录源控制流节点
        PointsTo::points_to(controlFlowNode, context, pointedObject, classObject, sourceControlFlowNode) and
        context.getDepth() = contextDepth
      )
  ) and
  // 计算压缩效率：唯一事实数量与关系总大小的百分比
  compressionEfficiency = 100.0 * uniqueFactsCount / totalRelationsSize
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩效率
select contextDepth, uniqueFactsCount, totalRelationsSize, compressionEfficiency