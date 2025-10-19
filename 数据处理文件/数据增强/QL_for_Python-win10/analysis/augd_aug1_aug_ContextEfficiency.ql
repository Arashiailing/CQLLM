/**
 * 分析指向关系图的压缩效率指标：统计唯一事实数量、关系图总大小，
 * 并计算它们相对于上下文深度的压缩比率。
 * 该查询有助于评估点对分析中数据结构的优化程度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩比率
from int distinctFactsNum, int relationsTotalSize, int contextDepth, float compressionRatio
where
  // 获取当前分析的上下文深度
  exists(PointsToContext ctx | contextDepth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同的(控制流节点, 被指向对象, 类对象)组合
  distinctFactsNum =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject classObject |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向对象，且该对象是类对象的实例
        PointsTo::points_to(controlFlowNode, ctx, pointedObject, classObject, _) and
        ctx.getDepth() = contextDepth
      )
    ) and
  // 计算关系总大小：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)组合
  relationsTotalSize =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject classObject, 
      PointsToContext ctx, ControlFlowNode sourceControlFlowNode |
      // 验证在指定上下文中，控制流节点指向对象，且该对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(controlFlowNode, ctx, pointedObject, classObject, sourceControlFlowNode) and
      ctx.getDepth() = contextDepth
    ) and
  // 计算压缩比率：唯一事实数量占关系总大小的百分比
  compressionRatio = 100.0 * distinctFactsNum / relationsTotalSize
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩比率
select contextDepth, distinctFactsNum, relationsTotalSize, compressionRatio