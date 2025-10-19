/**
 * 调用图结构量化分析：评估调用图的密度与结构效率。
 * 该查询通过分析调用事实数量、关系规模、上下文深度以及密度指标，
 * 综合评估调用图的数据密度和结构效率特性。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、totalRelations（关系总规模）、callContextDepth（上下文深度）和graphDensity（密度指标）
from int callFactCount, int totalRelations, int callContextDepth, float graphDensity
where
  // 计算调用图中的事实总数：统计所有(调用点, 被调用函数)对的数量
  callFactCount =
    strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        invocationPoint = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用点invocationPoint
        callContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(调用点, 被调用函数, 调用上下文)三元组的数量
  totalRelations =
    strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction, PointsToContext invocationContext |
      invocationPoint = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用点invocationPoint
      callContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
    ) and
  // 计算密度指标：将事实总数转换为相对于关系总规模的百分比
  graphDensity = 100.0 * callFactCount / totalRelations
select callContextDepth, callFactCount, totalRelations, graphDensity // 返回上下文深度、调用事实总数、关系总规模和密度指标