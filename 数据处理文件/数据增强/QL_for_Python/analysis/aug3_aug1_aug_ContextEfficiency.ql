/**
 * @name 指向关系图压缩效率分析
 * @description 本查询评估指向关系图的压缩效率，通过计算唯一事实的数量与关系图总大小的比例，
 *              分析不同上下文深度下的压缩效率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩效率
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 确定上下文深度
  exists(PointsToContext ctx | contextDepth = ctx.getDepth()) and
  (
    // 计算唯一事实数量：统计不同的(控制流节点, 被指向对象, 类对象)组合
    distinctFactsCount =
      strictcount(ControlFlowNode cfgNode, Object pointedObject, ClassObject classObject |
        exists(PointsToContext ctx |
          // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例
          PointsTo::points_to(cfgNode, ctx, pointedObject, classObject, _) and
          ctx.getDepth() = contextDepth
        )
      )
  ) and
  (
    // 计算关系总大小：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)组合
    totalRelationsSize =
      strictcount(ControlFlowNode cfgNode, Object pointedObject, ClassObject classObject, 
        PointsToContext ctx, ControlFlowNode sourceCfgNode |
        // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例，并记录源控制流节点
        PointsTo::points_to(cfgNode, ctx, pointedObject, classObject, sourceCfgNode) and
        ctx.getDepth() = contextDepth
      )
  ) and
  (
    // 计算压缩效率：唯一事实数量与关系总大小的百分比
    compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize
  )
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩效率
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio