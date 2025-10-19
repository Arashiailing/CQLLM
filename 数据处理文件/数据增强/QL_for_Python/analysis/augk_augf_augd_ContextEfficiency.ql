/**
 * 指向关系压缩效率评估：分析不同上下文深度下的数据压缩效果。
 * 本查询统计唯一事实与总关系的数量，并计算压缩比率指标。
 * 压缩比率表示唯一事实在总关系中的占比，用于评估指向关系压缩的效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：uniqueFactsCount（唯一事实数量）、overallRelationsCount（总关系数量）、ctxDepth（上下文深度）和compressionRate（压缩比率）
from int ctxDepth, int uniqueFactsCount, int overallRelationsCount, float compressionRate
where
  // 获取所有存在的上下文深度
  exists(PointsToContext ctx | ctxDepth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同的(控制流节点, 对象, 类对象)组合数量
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object objectVal, ClassObject classObject |
      exists(PointsToContext ctx |
        // 检查在给定上下文中，控制流节点指向特定对象和类对象
        PointsTo::points_to(flowNode, ctx, objectVal, classObject, _) and
        ctxDepth = ctx.getDepth()
      )
    ) and
  // 计算总关系数量：统计所有(控制流节点, 对象, 类对象, 上下文, 源节点)组合数量
  overallRelationsCount =
    strictcount(ControlFlowNode flowNode, Object objectVal, ClassObject classObject, 
      PointsToContext ctx, ControlFlowNode sourceNode |
      // 检查在给定上下文中，控制流节点指向特定对象和类对象，并记录源节点
      PointsTo::points_to(flowNode, ctx, objectVal, classObject, sourceNode) and
      ctxDepth = ctx.getDepth()
    ) and
  // 计算压缩比率：唯一事实数量占总关系数量的百分比
  compressionRate = 100.0 * uniqueFactsCount / overallRelationsCount and
  // 确保总关系数量不为零，避免除以零错误
  overallRelationsCount > 0
// 输出结果：上下文深度、唯一事实数量、总关系数量和压缩比率
select ctxDepth, uniqueFactsCount, overallRelationsCount, compressionRate