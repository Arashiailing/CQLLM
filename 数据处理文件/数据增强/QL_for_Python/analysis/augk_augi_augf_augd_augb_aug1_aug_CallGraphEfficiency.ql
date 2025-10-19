/**
 * Python函数调用网络密度分析：评估代码中函数间调用的密集程度与结构特性。
 * 本查询通过统计函数调用实例数量、调用关系总数、调用上下文深度以及计算密度比率，
 * 来量化分析调用图的紧密性，帮助识别可能需要优化的代码区域。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出指标说明：callInstanceCount（函数调用实例总数）、relationCount（调用关系总数）、contextDepth（调用上下文深度）和densityRatio（调用图密度比率）
from int callInstanceCount, int relationCount, int contextDepth, float densityRatio
where
  // 获取函数调用基础数据，包括调用位置、被调用函数及其执行上下文
  exists(ControlFlowNode callLocation, CallableValue calledFunction, PointsToContext callContext |
    callLocation = calledFunction.getACall(callContext) and
    contextDepth = callContext.getDepth() and
    // 统计函数调用实例总数：计算不同(调用位置, 目标函数)组合的数量
    callInstanceCount =
      strictcount(ControlFlowNode callerLocation, CallableValue targetFunction |
        exists(PointsToContext invocationCtx |
          callerLocation = targetFunction.getACall(invocationCtx)
        )
      ) and
    // 统计调用关系总数：计算所有(调用位置, 目标函数, 上下文)三元组的数量
    relationCount =
      strictcount(ControlFlowNode callerLocation, CallableValue targetFunction, PointsToContext invocationCtx |
        callerLocation = targetFunction.getACall(invocationCtx)
      ) and
    // 计算调用图密度比率：调用实例数占关系总数的百分比，反映调用网络的紧密程度
    densityRatio = 100.0 * callInstanceCount / relationCount
  )
select contextDepth, callInstanceCount, relationCount, densityRatio // 返回调用上下文深度、调用实例总数、关系总数和密度比率