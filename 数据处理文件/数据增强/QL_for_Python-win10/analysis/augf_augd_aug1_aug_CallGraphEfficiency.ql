/**
 * 调用图结构特性量化分析：评估调用图的数据密度与结构效率。
 * 本查询通过分析调用事实数量、关系规模、上下文深度，并计算结构密度指标，
 * 提供对调用图紧凑程度和结构优化空间的全面评估。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出指标：totalCallFacts（调用事实总数）、totalRelationSize（关系总规模）、callContextDepth（上下文深度）和structuralDensity（结构密度指标）
from int totalCallFacts, int totalRelationSize, int callContextDepth, float structuralDensity
where
  // 分析调用图中的事实总数：统计所有(调用节点, 目标函数)对的数量
  totalCallFacts =
    strictcount(ControlFlowNode invokingNode, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        invokingNode = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用节点invokingNode
        callContextDepth = invocationContext.getDepth() // 记录invocationContext的深度
      )
    ) and
  // 分析调用图关系的总规模：统计所有(调用节点, 目标函数, 调用上下文)三元组的数量
  totalRelationSize =
    strictcount(ControlFlowNode invokingNode, CallableValue targetFunction, PointsToContext invocationContext |
      invokingNode = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用节点invokingNode
      invocationContext.getDepth() = callContextDepth // 确保使用相同的上下文深度
    ) and
  // 计算结构密度指标：将事实总数转换为相对于关系总规模的百分比，反映调用图的紧凑程度
  structuralDensity = 100.0 * totalCallFacts / totalRelationSize
select callContextDepth, totalCallFacts, totalRelationSize, structuralDensity // 返回上下文深度、调用事实总数、关系总规模和结构密度指标