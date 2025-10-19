/**
 * @name 指向关系图压缩效率评估
 * @description 此查询用于分析指向关系图的压缩效率。它通过比较唯一事实的数量与整个关系图的大小，
 *              计算在不同上下文深度下的压缩效率百分比。压缩效率越高，表示数据压缩效果越好。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系图总大小、上下文深度和压缩效率百分比
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 确定当前分析的上下文深度
  exists(PointsToContext ctx | contextDepth = ctx.getDepth()) and
  (
    // 计算唯一事实数量：统计不同(controlNode, targetObject, clsObject)组合的数量
    distinctFactsCount =
      strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject clsObject |
        exists(PointsToContext ctx |
          // 验证在指定上下文中，控制节点指向目标对象，且该对象是类对象的实例
          PointsTo::points_to(controlNode, ctx, targetObject, clsObject, _) and
          ctx.getDepth() = contextDepth
        )
      )
  ) and
  (
    // 计算关系图总大小：统计所有(controlNode, targetObject, clsObject, ctx, sourceNode)组合的数量
    totalRelationsSize =
      strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject clsObject, 
        PointsToContext ctx, ControlFlowNode sourceNode |
        // 验证在指定上下文中，控制节点指向目标对象，该对象是类对象的实例，并记录源控制节点
        PointsTo::points_to(controlNode, ctx, targetObject, clsObject, sourceNode) and
        ctx.getDepth() = contextDepth
      )
  ) and
  (
    // 计算压缩效率百分比：唯一事实数量占关系图总大小的百分比
    compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize
  )
// 输出结果：上下文深度、唯一事实数量、关系图总大小和压缩效率百分比
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio