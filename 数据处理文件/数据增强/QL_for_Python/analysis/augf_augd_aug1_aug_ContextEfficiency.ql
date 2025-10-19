/**
 * 评估指向关系图的压缩效率：计算唯一事实数量、关系图总体大小，
 * 并基于上下文深度分析其压缩比率。
 * 此查询用于评估点对分析中数据结构的优化水平。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总大小、上下文深度和压缩比率
from int uniqueFactsCount, int totalRelationsSize, int ctxDepth, float compRatio
where
  // 获取当前分析的上下文深度
  exists(PointsToContext currentCtx | ctxDepth = currentCtx.getDepth()) and
  
  // 计算唯一事实数量：统计不同的(控制流节点, 被指向对象, 类对象)组合
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject clsObject |
      exists(PointsToContext analysisCtx |
        // 验证在指定上下文中，控制流节点指向对象，且该对象是类对象的实例
        PointsTo::points_to(flowNode, analysisCtx, targetObject, clsObject, _) and
        analysisCtx.getDepth() = ctxDepth
      )
    ) and
    
  // 计算关系总大小：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)组合
  totalRelationsSize =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject clsObject, 
      PointsToContext analysisCtx, ControlFlowNode sourceFlowNode |
      // 验证在指定上下文中，控制流节点指向对象，且该对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(flowNode, analysisCtx, targetObject, clsObject, sourceFlowNode) and
      analysisCtx.getDepth() = ctxDepth
    ) and
    
  // 计算压缩比率：唯一事实数量占关系总大小的百分比
  compRatio = 100.0 * uniqueFactsCount / totalRelationsSize
// 输出结果：上下文深度、唯一事实数量、关系总大小和压缩比率
select ctxDepth, uniqueFactsCount, totalRelationsSize, compRatio