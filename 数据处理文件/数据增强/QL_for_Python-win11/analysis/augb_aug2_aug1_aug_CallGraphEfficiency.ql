/**
 * 调用图结构分析：量化评估调用图的紧凑度与效率。
 * 此查询通过统计调用事实、关系规模、上下文深度并计算密度指标，
 * 来衡量调用图的数据压缩效率和结构优化潜力，为代码重构提供参考。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出变量定义：callFactCount（调用事实总数）、callRelationCount（关系总规模）、
// callContextDepth（上下文深度）和callDensityMetric（密度指标）
from int callFactCount, int callRelationCount, int callContextDepth, float callDensityMetric
where
  // 计算调用事实总数：统计所有(调用节点, 被调用函数)二元组的数量
  // 同时提取上下文深度信息用于密度计算
  callFactCount =
    strictcount(ControlFlowNode invokingNode, CallableValue invokedFunction |
      exists(PointsToContext invocationContext |
        invokingNode = invokedFunction.getACall(invocationContext) and // 获取调用节点与被调用函数关系
        callContextDepth = invocationContext.getDepth() // 记录调用上下文深度
      )
    ) and
  // 计算调用图关系总规模：统计所有(调用节点, 被调用函数, 调用上下文)三元组的数量
  // 使用与事实计数相同的逻辑结构，确保计算基准一致
  callRelationCount =
    strictcount(ControlFlowNode invokingNode, CallableValue invokedFunction, PointsToContext invocationContext |
      invokingNode = invokedFunction.getACall(invocationContext) and // 获取完整调用关系三元组
      callContextDepth = invocationContext.getDepth() // 保持上下文深度一致性
    ) and
  // 计算密度指标：将事实总数转换为相对于关系总规模的百分比
  // 该指标反映调用图的结构紧凑度，数值越高表示信息密度越大
  callDensityMetric = 100.0 * callFactCount / callRelationCount
select callContextDepth, callFactCount, callRelationCount, callDensityMetric // 返回分析结果：上下文深度、调用事实数、关系规模和密度指标