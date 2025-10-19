/**
 * 调用图结构密度分析：量化评估函数调用关系图的紧凑性与结构效率。
 * 该查询通过统计调用事实数量、关系规模、上下文深度以及计算密度效率比率，
 * 全面分析调用图的数据分布特征和结构优化潜力。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：invocationFactCount（调用事实总数）、relationshipTotalSize（关系总规模）、
// invocationContextDepth（调用上下文深度）和densityEfficiencyRatio（密度效率比率）
from int invocationFactCount, int relationshipTotalSize, int invocationContextDepth, float densityEfficiencyRatio
where
  // 提取调用关系基础数据：收集所有调用源节点、目标函数及其调用上下文
  exists(ControlFlowNode invocationSource, CallableValue targetFunction, PointsToContext invocationContext |
    // 建立调用关系：源节点调用目标函数，并关联特定上下文
    invocationSource = targetFunction.getACall(invocationContext) and
    // 获取调用上下文的深度信息
    invocationContextDepth = invocationContext.getDepth() and
    // 计算调用事实总数：统计所有(源节点, 目标函数)调用对的数量
    invocationFactCount =
      strictcount(ControlFlowNode sourceNode, CallableValue targetFunc |
        exists(PointsToContext context |
          sourceNode = targetFunc.getACall(context)
        )
      ) and
    // 计算关系总规模：统计所有(源节点, 目标函数, 调用上下文)三元组的数量
    relationshipTotalSize =
      strictcount(ControlFlowNode sourceNode, CallableValue targetFunc, PointsToContext context |
        sourceNode = targetFunc.getACall(context)
      ) and
    // 计算密度效率比率：调用事实数占关系总数的百分比，反映调用图的紧凑程度
    densityEfficiencyRatio = 100.0 * invocationFactCount / relationshipTotalSize
  )
select invocationContextDepth, invocationFactCount, relationshipTotalSize, densityEfficiencyRatio // 返回调用上下文深度、调用事实总数、关系总规模和密度效率比率