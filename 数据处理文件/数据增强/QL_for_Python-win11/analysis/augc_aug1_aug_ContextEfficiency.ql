/**
 * 分析指向关系图的压缩效率指标：计算不同上下文深度下的唯一事实数量、
 * 关系图总大小，并评估压缩效率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩效率
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 确定当前分析的上下文深度
  exists(PointsToContext ctx | contextDepth = ctx.getDepth()) and
  
  // 计算唯一事实数量：统计不同的(控制流节点, 被指向对象, 类对象)组合
  distinctFactsCount = strictcount(
    ControlFlowNode controlNode, Object targetObject, ClassObject classObj |
      // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例
      exists(PointsToContext ctx |
        PointsTo::points_to(controlNode, ctx, targetObject, classObj, _) and
        ctx.getDepth() = contextDepth
      )
  ) and
  
  // 计算关系总大小：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)组合
  totalRelationsSize = strictcount(
    ControlFlowNode controlNode, Object targetObject, ClassObject classObj, 
    PointsToContext ctx, ControlFlowNode sourceControlNode |
      // 检查在给定上下文中，控制流节点是否指向对象，且该对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(controlNode, ctx, targetObject, classObj, sourceControlNode) and
      ctx.getDepth() = contextDepth
  ) and
  
  // 计算压缩效率：唯一事实数量与关系总大小的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize

// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩效率
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio