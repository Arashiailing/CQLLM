/**
 * 调用图结构量化分析：评估调用图的密度与结构效率。
 * 
 * 本查询通过以下指标综合评估调用图的数据密度和结构效率特性：
 * - 调用事实总数：统计调用点与目标函数的映射关系数量
 * - 关系总规模：统计包含调用上下文的三元组关系数量
 * - 上下文深度：记录调用上下文的深度信息
 * - 密度指标：计算调用事实相对于关系规模的百分比，评估调用图密度
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：调用事实总数、关系总规模、上下文深度和调用图密度指标
from int invocationFactCount, int relationshipTotalSize, int invocationContextDepth, float invocationGraphDensity
where
  // 计算调用事实总数：统计所有(调用点, 目标函数)对的数量
  invocationFactCount =
    strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        invocationPoint = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用点invocationPoint
        invocationContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(调用点, 目标函数, 调用上下文)三元组的数量
  relationshipTotalSize =
    strictcount(ControlFlowNode invocationPoint, CallableValue targetFunction, PointsToContext invocationContext |
      invocationPoint = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用点invocationPoint
      invocationContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
    ) and
  // 计算调用图密度指标：将调用事实总数转换为相对于关系总规模的百分比
  invocationGraphDensity = 100.0 * invocationFactCount / relationshipTotalSize
select invocationContextDepth, invocationFactCount, relationshipTotalSize, invocationGraphDensity // 返回上下文深度、调用事实总数、关系总规模和密度指标