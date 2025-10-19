/**
 * 调用图结构量化分析：评估调用图的紧凑度与信息密度。
 * 本查询通过统计调用事实基数、关系规模、上下文深度并计算密度指标，
 * 量化调用图的数据压缩效率和结构优化空间，为代码重构提供数据支持。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出变量定义：invocationFactCount（调用事实基数）、invocationRelationCount（关系规模）、
// invocationContextDepth（上下文深度）和invocationDensityMetric（密度指标）
from int invocationFactCount, int invocationRelationCount, int invocationContextDepth, float invocationDensityMetric
where
  // 计算调用事实基数：统计所有(调用者节点, 被调用函数)二元组的数量
  // 同时记录上下文深度信息用于后续密度计算
  invocationFactCount =
    strictcount(ControlFlowNode callerNode, CallableValue calleeFunction |
      exists(PointsToContext callContext |
        callerNode = calleeFunction.getACall(callContext) and // 提取调用者与被调用者关系
        invocationContextDepth = callContext.getDepth() // 记录调用上下文深度
      )
    ) and
  // 计算调用图关系规模：统计所有(调用者节点, 被调用函数, 调用上下文)三元组的数量
  // 使用与事实基数计算相同的逻辑结构，确保计算基准一致
  invocationRelationCount =
    strictcount(ControlFlowNode callerNode, CallableValue calleeFunction, PointsToContext callContext |
      callerNode = calleeFunction.getACall(callContext) and // 提取完整调用关系三元组
      invocationContextDepth = callContext.getDepth() // 保持上下文深度一致性
    ) and
  // 计算密度指标：将调用事实基数转换为相对于关系规模的百分比
  // 该指标反映调用图的结构紧凑度，数值越高表示信息密度越大
  invocationDensityMetric = 100.0 * invocationFactCount / invocationRelationCount
select invocationContextDepth, invocationFactCount, invocationRelationCount, invocationDensityMetric // 返回分析结果：上下文深度、调用事实基数、关系规模和密度指标