/**
 * 调用图结构量化分析：评估调用图的密度与结构效率。
 * 该查询通过统计调用事实数量、关系规模、上下文深度以及计算密度比率，
 * 对调用图的数据密度和结构效率进行量化评估，为代码性能优化提供数据支持。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、callRelationCount（关系总规模）、
// callContextDepth（上下文深度）和callDensityRatio（密度比率）
from int callFactCount, int callRelationCount, int callContextDepth, float callDensityRatio
where
  // 第一部分：计算调用图中的事实总数
  // 统计所有(调用点, 目标函数)对的数量，反映调用图的基本规模
  callFactCount =
    strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        invocationPoint = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用点invocationPoint
        callContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
      )
    ) and
  // 第二部分：计算调用图关系的总规模
  // 统计所有(调用点, 目标函数, 调用上下文)三元组的数量，反映调用图的详细程度
  callRelationCount =
    strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction, PointsToContext invocationContext |
      invocationPoint = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用点invocationPoint
      callContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
    ) and
  // 第三部分：计算密度比率
  // 将调用事实总数转换为相对于关系总规模的百分比，反映调用图的紧凑程度
  callDensityRatio = 100.0 * callFactCount / callRelationCount
select callContextDepth, callFactCount, callRelationCount, callDensityRatio // 返回上下文深度、调用事实总数、关系总规模和密度比率