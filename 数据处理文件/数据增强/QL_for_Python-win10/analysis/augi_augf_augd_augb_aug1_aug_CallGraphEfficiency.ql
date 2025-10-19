/**
 * 调用图结构密度评估：分析Python代码中函数调用网络的紧密程度与性能特征。
 * 该查询通过量化调用实例数量、关系总数、上下文深度以及密度比率，
 * 来评估调用图的结构特性，从而识别潜在的代码优化点。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出指标定义：totalCallInstances（调用实例总数）、totalRelations（关系总数）、callContextDepth（调用上下文深度）和graphDensityRatio（密度比率）
from int totalCallInstances, int totalRelations, int callContextDepth, float graphDensityRatio
where
  // 获取调用关系的基础数据，包括调用点、目标函数及其上下文
  exists(ControlFlowNode invocationSite, CallableValue targetCallable, PointsToContext invocationContext |
    invocationSite = targetCallable.getACall(invocationContext) and
    callContextDepth = invocationContext.getDepth() and
    // 计算调用实例总数：统计不同(调用点, 目标函数)对的数量
    totalCallInstances =
      strictcount(ControlFlowNode callSite, CallableValue calledTarget |
        exists(PointsToContext context |
          callSite = calledTarget.getACall(context)
        )
      ) and
    // 计算关系总数：统计所有(调用点, 目标函数, 上下文)三元组的数量
    totalRelations =
      strictcount(ControlFlowNode callSite, CallableValue calledTarget, PointsToContext context |
        callSite = calledTarget.getACall(context)
      ) and
    // 计算密度比率：调用实例数占关系总数的百分比，反映调用图的紧密程度
    graphDensityRatio = 100.0 * totalCallInstances / totalRelations
  )
select callContextDepth, totalCallInstances, totalRelations, graphDensityRatio // 返回调用上下文深度、调用实例总数、关系总数和密度比率