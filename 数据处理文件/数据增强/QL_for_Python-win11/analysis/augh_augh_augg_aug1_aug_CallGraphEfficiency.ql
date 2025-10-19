/**
 * 调用图结构量化评估：分析调用图的紧凑性与结构效率。
 * 本查询通过计算调用事实数量、关系规模、上下文深度并推导密度比率，
 * 对调用图的数据密度和结构效率进行量化分析，为代码性能优化提供依据。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：totalCallFacts（调用事实总数）、totalCallRelations（关系总规模）、
// contextDepth（上下文深度）和densityRatio（密度比率）
from int totalCallFacts, int totalCallRelations, int contextDepth, float densityRatio
where
  // 统计调用事实数量：计算所有(调用点, 目标函数)对的数量，反映调用图的基本规模
  // 同时记录调用上下文的深度，用于后续分析
  totalCallFacts =
    strictcount(ControlFlowNode callSite, CallableValue calledFunction |
      exists(PointsToContext callContext |
        callSite = calledFunction.getACall(callContext) and // 获取calledFunction在callContext中的调用点callSite
        contextDepth = callContext.getDepth() // 记录callContext的深度
      )
    ) and
  // 统计调用关系规模：计算所有(调用点, 目标函数, 调用上下文)三元组的数量
  // 反映调用图的详细程度和上下文敏感性
  totalCallRelations =
    strictcount(ControlFlowNode callSite, CallableValue calledFunction, PointsToContext callContext |
      callSite = calledFunction.getACall(callContext) and // 获取calledFunction在callContext中的调用点callSite
      contextDepth = callContext.getDepth() // 记录callContext的深度
    ) and
  // 计算密度比率：将调用事实总数转换为相对于关系总规模的百分比
  // 反映调用图的紧凑程度，值越高表示调用图越紧凑
  densityRatio = 100.0 * totalCallFacts / totalCallRelations
select contextDepth, totalCallFacts, totalCallRelations, densityRatio // 返回上下文深度、调用事实总数、关系总规模和密度比率