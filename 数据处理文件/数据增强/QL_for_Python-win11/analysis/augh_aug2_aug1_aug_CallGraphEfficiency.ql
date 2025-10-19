/**
 * 调用图结构密度与效率分析：评估调用图的信息密度与结构优化水平。
 * 该查询通过量化调用事实数量、关系规模、上下文深度及密度指标，
 * 衡量调用图的数据压缩效率和结构紧凑性，为代码结构优化提供量化参考。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、totalRelationSize（关系总规模）、callContextDepth（调用上下文深度）和structureDensityMetric（结构密度指标）
from int callFactCount, int totalRelationSize, int callContextDepth, float structureDensityMetric
where
  // 统计调用事实总数：计算所有(调用节点, 目标函数)二元组的数量
  // 同时提取调用上下文深度信息用于后续分析
  callFactCount =
    strictcount(ControlFlowNode invokingNode, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        invokingNode = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用节点invokingNode
        callContextDepth = invocationContext.getDepth() // 记录invocationContext的深度信息
      )
    ) and
  // 计算调用图关系总规模：统计所有(调用节点, 目标函数, 调用上下文)三元组的数量
  // 保持与事实计数相同的逻辑结构，确保计算基准一致
  totalRelationSize =
    strictcount(ControlFlowNode invokingNode, CallableValue targetFunction, PointsToContext invocationContext |
      invokingNode = targetFunction.getACall(invocationContext) and // 获取targetFunction在invocationContext中的调用节点invokingNode
      callContextDepth = invocationContext.getDepth() // 确保使用相同的上下文深度
    ) and
  // 计算结构密度指标：将调用事实总数转换为相对于关系总规模的百分比密度
  // 该指标量化调用图的紧凑程度，数值越高表示结构越紧凑高效
  structureDensityMetric = 100.0 * callFactCount / totalRelationSize
select callContextDepth, callFactCount, totalRelationSize, structureDensityMetric // 返回调用上下文深度、调用事实总数、关系总规模和结构密度指标