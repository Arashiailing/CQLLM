/**
 * 函数调用图结构密度分析：评估代码中函数调用网络的紧密性与性能特征。
 * 本查询通过量化调用实例数量、关系总数、上下文深度以及密度比率，
 * 来分析调用图的结构特性，识别可能的优化空间。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出指标定义：invocationInstanceCount（调用实例总数）、totalRelationCount（关系总数）、callContextDepth（调用上下文深度）和callDensityRatio（密度比率）
from int invocationInstanceCount, int totalRelationCount, int callContextDepth, float callDensityRatio
where
  // 获取调用关系的基础数据，包括调用点、目标函数及其上下文
  exists(ControlFlowNode invocationSite, CallableValue targetFunction, PointsToContext invocationContext |
    invocationSite = targetFunction.getACall(invocationContext) and
    callContextDepth = invocationContext.getDepth() and
    // 计算调用实例总数：统计不同(调用点, 目标函数)对的数量
    invocationInstanceCount =
      strictcount(ControlFlowNode callSite, CallableValue calledFunction |
        exists(PointsToContext callCtx |
          callSite = calledFunction.getACall(callCtx)
        )
      ) and
    // 计算关系总数：统计所有(调用点, 目标函数, 上下文)三元组的数量
    totalRelationCount =
      strictcount(ControlFlowNode callSite, CallableValue calledFunction, PointsToContext callCtx |
        callSite = calledFunction.getACall(callCtx)
      ) and
    // 计算密度比率：调用实例数占关系总数的百分比，反映调用图的紧密程度
    callDensityRatio = 100.0 * invocationInstanceCount / totalRelationCount
  )
select callContextDepth, invocationInstanceCount, totalRelationCount, callDensityRatio // 返回调用上下文深度、调用实例总数、关系总数和密度比率