/**
 * 调用图统计特性分析：评估调用图的紧凑性与上下文复用效率。
 * 本查询量化分析调用图的关键指标，包括调用事实基数、上下文关系规模，
 * 以及基于调用上下文深度的复用效率比率，用于衡量调用节点在不同上下文中的复用程度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询输出变量：analysisDepth（分析深度）、callFactCount（调用事实基数）、
// contextRelationSize（上下文关系规模）和reuseEfficiency（复用效率比率）
from int analysisDepth, int callFactCount, int contextRelationSize, float reuseEfficiency
where
  // 确定分析深度并计算调用图统计指标
  exists(PointsToContext ctx |
    analysisDepth = ctx.getDepth() and // 设置当前分析的上下文深度
    
    // 计算调用事实基数：统计唯一的(调用节点, 被调用函数)对的数量
    callFactCount = strictcount(ControlFlowNode invocationNode, CallableValue calledFunction |
      exists(PointsToContext evaluationContext |
        invocationNode = calledFunction.getACall(evaluationContext) and // 验证调用关系
        evaluationContext.getDepth() = analysisDepth // 确保在指定深度下统计
      )
    ) and
    
    // 计算上下文关系规模：统计包含上下文信息的(调用节点, 被调用函数, 评估上下文)三元组数量
    contextRelationSize = strictcount(ControlFlowNode invocationNode, CallableValue calledFunction, PointsToContext evaluationContext |
      invocationNode = calledFunction.getACall(evaluationContext) and // 验证调用关系
      evaluationContext.getDepth() = analysisDepth // 确保在指定深度下统计
    ) and
    
    // 计算复用效率比率：调用事实基数与上下文关系规模的比值，转换为百分比形式
    // 比率越高表示相同调用在不同上下文中的复用程度越高，调用图越紧凑
    reuseEfficiency = 100.0 * callFactCount / contextRelationSize
  )
select analysisDepth, callFactCount, contextRelationSize, reuseEfficiency // 输出分析结果：分析深度、调用事实基数、上下文关系规模和复用效率比率