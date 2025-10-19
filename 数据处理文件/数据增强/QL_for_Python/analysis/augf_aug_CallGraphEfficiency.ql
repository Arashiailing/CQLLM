/**
 * 调用图紧凑性度量分析：评估调用图中事实数量与关系大小的比例关系。
 * 本查询通过计算(ControlFlowNode, CallableValue)对与三元组(ControlFlowNode, CallableValue, PointsToContext)的比率，
 * 来量化调用图的紧凑程度，并记录上下文深度信息。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：totalFacts（事实总数）、totalRelations（关系总大小）、callContextDepth（上下文深度）和compactnessMetric（紧凑性指标）
from int totalFacts, int totalRelations, int callContextDepth, float compactnessMetric
where
  // 获取所有调用上下文的深度信息，确保每个上下文只计算一次
  exists(PointsToContext callSiteContext |
    callContextDepth = callSiteContext.getDepth() and
    // 计算调用图中的事实总数：统计所有调用节点与目标函数的映射对
    totalFacts =
      strictcount(ControlFlowNode invocationNode, CallableValue targetFunction |
        invocationNode = targetFunction.getACall(callSiteContext)
      ) and
    // 计算调用图关系的总大小：统计包含上下文信息的三元组数量
    totalRelations =
      strictcount(ControlFlowNode invocationNode, CallableValue targetFunction |
        invocationNode = targetFunction.getACall(callSiteContext)
      ) and
    // 计算调用图紧凑性指标：事实数量相对于关系大小的百分比
    compactnessMetric = 100.0 * totalFacts / totalRelations
  )
select callContextDepth, totalFacts, totalRelations, compactnessMetric // 输出上下文深度、事实总数、关系总大小和紧凑性指标