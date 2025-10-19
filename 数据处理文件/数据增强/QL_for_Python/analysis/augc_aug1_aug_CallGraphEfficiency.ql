/**
 * 调用图结构分析：量化评估调用图的密度与效率特性。
 * 本查询通过分析调用事实数量、关系规模、上下文深度以及密度指标，
 * 来综合评估调用图的数据密度和结构效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：factCount（调用事实总数）、relationCount（关系总规模）、contextDepth（上下文深度）和densityMetric（密度指标）
from int factCount, int relationCount, int contextDepth, float densityMetric
where
  // 计算调用图中的事实总数：统计所有(调用点, 被调用函数)对的数量
  factCount =
    strictcount(ControlFlowNode callSite, CallableValue calleeFunction |
      exists(PointsToContext callContext |
        callSite = calleeFunction.getACall(callContext) and // 获取calleeFunction在callContext中的调用点callSite
        contextDepth = callContext.getDepth() // 记录callContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(调用点, 被调用函数, 调用上下文)三元组的数量
  relationCount =
    strictcount(ControlFlowNode callSite, CallableValue calleeFunction, PointsToContext callContext |
      callSite = calleeFunction.getACall(callContext) and // 获取calleeFunction在callContext中的调用点callSite
      contextDepth = callContext.getDepth() // 记录callContext的深度
    ) and
  // 计算密度指标：将事实总数转换为相对于关系总规模的百分比
  densityMetric = 100.0 * factCount / relationCount
select contextDepth, factCount, relationCount, densityMetric // 返回上下文深度、调用事实总数、关系总规模和密度指标