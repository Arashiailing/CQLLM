/**
 * 函数调用图结构密度评估：分析代码中函数调用网络的紧凑程度与性能特征。
 * 该查询通过计算调用实例数量、关系总数、上下文深度以及效率比率，
 * 来量化评估调用图的结构特性与优化潜力。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出指标：invocationCount（调用实例总数）、totalRelations（关系总数）、callContextDepth（调用上下文深度）和efficiencyRatio（效率比率）
from int invocationCount, int totalRelations, int callContextDepth, float efficiencyRatio
where
  // 获取调用关系的基础数据，包括调用点、目标函数及其上下文
  exists(ControlFlowNode invocationSite, CallableValue targetFunction, PointsToContext invocationContext |
    invocationSite = targetFunction.getACall(invocationContext) and
    callContextDepth = invocationContext.getDepth() and
    // 计算调用实例总数：统计不同(调用点, 目标函数)对的数量
    invocationCount =
      strictcount(ControlFlowNode callSite, CallableValue calledFunc |
        exists(PointsToContext context |
          callSite = calledFunc.getACall(context)
        )
      ) and
    // 计算关系总数：统计所有(调用点, 目标函数, 上下文)三元组的数量
    totalRelations =
      strictcount(ControlFlowNode callSite, CallableValue calledFunc, PointsToContext context |
        callSite = calledFunc.getACall(context)
      ) and
    // 计算效率比率：调用实例数占关系总数的百分比，反映调用图的紧凑程度
    efficiencyRatio = 100.0 * invocationCount / totalRelations
  )
select callContextDepth, invocationCount, totalRelations, efficiencyRatio // 返回调用上下文深度、调用实例总数、关系总数和效率比率