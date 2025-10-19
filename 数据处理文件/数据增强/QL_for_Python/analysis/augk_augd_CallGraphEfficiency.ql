/**
 * 此查询旨在评估调用图的性能特性，具体包括：
 * - 计算调用图中唯一调用对的数量（即不同调用节点与被调用函数的组合数）
 * - 测量调用图关系的总体规模（考虑上下文信息的完整调用关系总数）
 * - 分析调用图的压缩效率（通过计算唯一调用对数量与总关系数的比率，以百分比形式呈现）
 * 所有分析结果均根据调用上下文的深度进行分组展示
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：uniqueCallPairsCount（唯一调用对数量）、totalCallRelationsCount（总调用关系数）、callContextDepth（调用上下文深度）和compressionEfficiency（压缩效率）
from int uniqueCallPairsCount, int totalCallRelationsCount, int callContextDepth, float compressionEfficiency
where
  // 计算调用图中唯一的调用节点与被调用函数组合数量
  uniqueCallPairsCount =
    strictcount(ControlFlowNode callSite, CallableValue targetFunction |
      exists(PointsToContext context |
        callSite = targetFunction.getACall(context) and // 获取函数在特定上下文中的调用位置
        callContextDepth = context.getDepth() // 记录调用上下文的深度
      )
    ) and
  // 计算包含上下文信息的完整调用关系总数
  totalCallRelationsCount =
    strictcount(ControlFlowNode callSite, CallableValue targetFunction, PointsToContext context |
      callSite = targetFunction.getACall(context) and // 获取函数在特定上下文中的调用位置
      callContextDepth = context.getDepth() // 确保使用相同深度的调用上下文
    ) and
  // 计算调用图的压缩效率百分比
  compressionEfficiency = 100.0 * uniqueCallPairsCount / totalCallRelationsCount
select callContextDepth, uniqueCallPairsCount, totalCallRelationsCount, compressionEfficiency // 输出按调用上下文深度分组的分析结果