/**
 * 调用图结构密度分析：评估代码中函数调用网络的紧密性与性能特征。
 * 本查询通过量化调用实例数量、关系总数、上下文深度以及密度比率，
 * 来分析调用图的结构特性，识别可能的优化空间。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出指标定义：callInstanceCount（调用实例总数）、relationCount（关系总数）、contextDepth（调用上下文深度）和densityRatio（密度比率）
from int callInstanceCount, int relationCount, int contextDepth, float densityRatio
where
  // 获取调用关系的基础数据，包括调用点、目标函数及其上下文
  exists(ControlFlowNode callPoint, CallableValue calledFunction, PointsToContext callContext |
    callPoint = calledFunction.getACall(callContext) and
    contextDepth = callContext.getDepth() and
    // 计算调用实例总数：统计不同(调用点, 目标函数)对的数量
    callInstanceCount =
      strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction |
        exists(PointsToContext context |
          invocationPoint = targetFunction.getACall(context)
        )
      ) and
    // 计算关系总数：统计所有(调用点, 目标函数, 上下文)三元组的数量
    relationCount =
      strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction, PointsToContext context |
        invocationPoint = targetFunction.getACall(context)
      ) and
    // 计算密度比率：调用实例数占关系总数的百分比，反映调用图的紧密程度
    densityRatio = 100.0 * callInstanceCount / relationCount
  )
select contextDepth, callInstanceCount, relationCount, densityRatio // 返回调用上下文深度、调用实例总数、关系总数和密度比率