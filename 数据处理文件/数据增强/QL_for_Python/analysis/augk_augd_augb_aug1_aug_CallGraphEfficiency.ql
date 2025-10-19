/**
 * 调用图结构密度分析：评估代码中函数调用网络的紧凑性与性能特征。
 * 本查询通过统计调用实例数量、关系总数、上下文深度以及计算效率比率，
 * 来量化分析调用图的结构特性并识别优化空间。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出指标定义：callInstanceCount（调用实例总数）、relationTotal（关系总数）、contextDepth（调用上下文深度）和callEfficiencyRatio（效率比率）
from int callInstanceCount, int relationTotal, int contextDepth, float callEfficiencyRatio
where
  // 获取调用关系的基础数据，包括调用点、目标函数及其上下文
  exists(ControlFlowNode callPoint, CallableValue calledFunction, PointsToContext callContext |
    callPoint = calledFunction.getACall(callContext) and
    contextDepth = callContext.getDepth() and
    // 计算调用实例总数：统计不同(调用点, 目标函数)对的数量
    callInstanceCount =
      strictcount(ControlFlowNode callerSite, CallableValue targetFunc |
        exists(PointsToContext callCtx |
          callerSite = targetFunc.getACall(callCtx)
        )
      ) and
    // 计算关系总数：统计所有(调用点, 目标函数, 上下文)三元组的数量
    relationTotal =
      strictcount(ControlFlowNode callerSite, CallableValue targetFunc, PointsToContext callCtx |
        callerSite = targetFunc.getACall(callCtx)
      ) and
    // 计算效率比率：调用实例数占关系总数的百分比，反映调用图的紧凑程度
    callEfficiencyRatio = 100.0 * callInstanceCount / relationTotal
  )
select contextDepth, callInstanceCount, relationTotal, callEfficiencyRatio // 返回调用上下文深度、调用实例总数、关系总数和效率比率