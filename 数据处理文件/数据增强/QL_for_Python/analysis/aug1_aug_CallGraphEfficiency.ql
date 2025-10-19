/**
 * 调用图统计特性分析：评估调用图的紧凑性与结构效率。
 * 本查询通过计算调用事实数量、关系规模、上下文深度以及紧凑性比率，
 * 来量化分析调用图的数据密度和结构效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：totalFacts（调用事实总数）、totalRelations（关系总规模）、ctxDepth（上下文深度）和compactnessRatio（紧凑性比率）
from int totalFacts, int totalRelations, int ctxDepth, float compactnessRatio
where
  // 计算调用图中的事实总数：统计所有(调用节点, 目标函数)对的数量
  totalFacts =
    strictcount(ControlFlowNode invocationNode, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        invocationNode = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用节点invocationNode
        ctxDepth = invocationContext.getDepth() // 记录invocationContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(调用节点, 目标函数, 调用上下文)三元组的数量
  totalRelations =
    strictcount(ControlFlowNode invocationNode, CallableValue targetFunction, PointsToContext invocationContext |
      invocationNode = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用节点invocationNode
      ctxDepth = invocationContext.getDepth() // 记录invocationContext的深度
    ) and
  // 计算紧凑性比率：将事实总数转换为相对于关系总规模的百分比
  compactnessRatio = 100.0 * totalFacts / totalRelations
select ctxDepth, totalFacts, totalRelations, compactnessRatio // 返回上下文深度、调用事实总数、关系总规模和紧凑性比率