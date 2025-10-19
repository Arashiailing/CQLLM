/**
 * 调用图结构特性分析：量化评估调用图的数据密度与结构效率。
 * 该查询通过统计调用事实数量、关系规模、上下文深度，并计算密度指标，
 * 来全面分析调用图的紧凑程度和结构优化空间。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、relationScale（关系总规模）、contextDepth（上下文深度）和densityMetric（密度指标）
from int callFactCount, int relationScale, int contextDepth, float densityMetric
where
  // 计算调用图中的事实总数：统计所有(调用节点, 被调用函数)对的数量
  callFactCount =
    strictcount(ControlFlowNode callerNode, CallableValue calleeFunction |
      exists(PointsToContext callContext |
        callerNode = calleeFunction.getACall(callContext) and // 获取calleeFunction在callContext中的调用节点callerNode
        contextDepth = callContext.getDepth() // 记录callContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(调用节点, 被调用函数, 调用上下文)三元组的数量
  relationScale =
    strictcount(ControlFlowNode callerNode, CallableValue calleeFunction, PointsToContext callContext |
      callerNode = calleeFunction.getACall(callContext) and // 获取calleeFunction在callContext中的调用节点callerNode
      callContext.getDepth() = contextDepth // 确保使用相同的上下文深度
    ) and
  // 计算密度指标：将事实总数转换为相对于关系总规模的百分比，反映调用图的紧凑程度
  densityMetric = 100.0 * callFactCount / relationScale
select contextDepth, callFactCount, relationScale, densityMetric // 返回上下文深度、调用事实总数、关系总规模和密度指标