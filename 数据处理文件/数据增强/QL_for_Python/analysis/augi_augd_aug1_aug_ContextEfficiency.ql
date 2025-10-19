/**
 * 评估点对分析关系图的压缩性能：计算唯一事实的数量、关系图总体积，
 * 以及它们相对于上下文层级的压缩效率。
 * 此查询用于衡量点对分析中数据结构的优化水平。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：唯一事实计数、关系总大小、上下文层级和压缩效率
from int uniqueFactsCount, int totalRelationsSize, int ctxDepth, float compressionRate
where
  // 获取当前分析的上下文层级
  exists(PointsToContext ctx | ctxDepth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同的(流节点, 目标对象, 类对象)组合
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject clsObject |
      exists(PointsToContext ctx |
        PointsTo::points_to(flowNode, ctx, targetObject, clsObject, _) and
        ctx.getDepth() = ctxDepth
      )
    ) and
  // 计算关系总大小：统计所有(流节点, 目标对象, 类对象, 上下文, 源流节点)组合
  totalRelationsSize =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject clsObject, 
      PointsToContext ctx, ControlFlowNode sourceFlowNode |
      PointsTo::points_to(flowNode, ctx, targetObject, clsObject, sourceFlowNode) and
      ctx.getDepth() = ctxDepth
    ) and
  // 计算压缩效率：唯一事实数量占关系总大小的百分比
  compressionRate = 100.0 * uniqueFactsCount / totalRelationsSize
// 输出结果：上下文层级、唯一事实计数、关系总大小和压缩效率
select ctxDepth, uniqueFactsCount, totalRelationsSize, compressionRate