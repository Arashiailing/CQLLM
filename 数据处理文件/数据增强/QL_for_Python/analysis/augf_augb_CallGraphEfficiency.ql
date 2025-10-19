/**
 * 调用图统计特性分析：评估调用节点在不同上下文中的复用效率。
 * 通过量化调用事实总数、关系总规模及上下文深度，分析调用图的紧凑性。
 * 高效率比率表明相同调用节点在多个上下文中被有效复用。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：analysisDepth（上下文深度）、callFactCount（调用事实总数）、
// totalRelationSize（关系总规模）和reuseEfficiency（复用效率比率）
from int analysisDepth, int callFactCount, int totalRelationSize, float reuseEfficiency
where
  // 基于上下文深度计算调用图的关键统计指标
  exists(PointsToContext contextInstance |
    // 设置当前分析的上下文深度
    analysisDepth = contextInstance.getDepth() and
    
    // 计算调用事实总数：统计不同(调用节点, 被调用函数)对的数量
    callFactCount = strictcount(ControlFlowNode invocationNode, CallableValue calledFunction |
      exists(PointsToContext evaluationContext |
        // 确认调用关系并确保在相同深度下计算
        invocationNode = calledFunction.getACall(evaluationContext) and
        evaluationContext.getDepth() = analysisDepth
      )
    ) and
    
    // 计算关系总规模：统计包含上下文信息的(调用节点, 被调用函数, 上下文)三元组数量
    totalRelationSize = strictcount(ControlFlowNode invocationNode, CallableValue calledFunction, PointsToContext evaluationContext |
      // 确认调用关系并确保在相同深度下计算
      invocationNode = calledFunction.getACall(evaluationContext) and
      evaluationContext.getDepth() = analysisDepth
    ) and
    
    // 计算复用效率比率：调用事实总数与关系总规模的比值，转换为百分比形式
    // 该比率越高，表示相同调用在不同上下文中复用程度越高
    reuseEfficiency = 100.0 * callFactCount / totalRelationSize
  )
select analysisDepth, callFactCount, totalRelationSize, reuseEfficiency // 输出分析结果：上下文深度、调用事实总数、关系总规模和复用效率比率