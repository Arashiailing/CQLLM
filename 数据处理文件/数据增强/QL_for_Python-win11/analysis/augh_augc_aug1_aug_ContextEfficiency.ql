/**
 * 评估指向关系图的压缩性能：度量不同上下文深度级别中的唯一事实计数、
 * 整个关系图的规模，并计算压缩效率百分比。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询输出变量：唯一事实计数、关系图总规模、上下文深度级别和压缩效率百分比
from int uniqueFactsCount, int totalGraphSize, int ctxDepth, float efficiencyPercentage
where
  // 确定当前评估的上下文深度级别
  exists(PointsToContext ctx | ctxDepth = ctx.getDepth()) and
  
  // 计算唯一事实计数：统计不同的(控制流节点, 被指向对象, 类对象)元组数量
  uniqueFactsCount = strictcount(
    ControlFlowNode node, Object pointedObj, ClassObject clsObj |
      // 验证在指定上下文中，控制流节点是否指向对象，且该对象是类对象的实例
      exists(PointsToContext ctx |
        PointsTo::points_to(node, ctx, pointedObj, clsObj, _) and
        ctx.getDepth() = ctxDepth
      )
  ) and
  
  // 计算关系图总规模：统计所有(控制流节点, 被指向对象, 类对象, 上下文, 源控制流节点)元组数量
  totalGraphSize = strictcount(
    ControlFlowNode node, Object pointedObj, ClassObject clsObj, 
    PointsToContext ctx, ControlFlowNode sourceNode |
      // 验证在指定上下文中，控制流节点是否指向对象，且该对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(node, ctx, pointedObj, clsObj, sourceNode) and
      ctx.getDepth() = ctxDepth
  ) and
  
  // 计算压缩效率百分比：唯一事实计数与关系图总规模的比率
  efficiencyPercentage = 100.0 * uniqueFactsCount / totalGraphSize

// 输出结果：上下文深度级别、唯一事实计数、关系图总规模和压缩效率百分比
select ctxDepth, uniqueFactsCount, totalGraphSize, efficiencyPercentage