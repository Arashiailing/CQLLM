/**
 * 调用图结构密度分析：评估函数调用关系图的紧凑性与效率指标。
 * 本查询通过统计调用事实数量、关系规模、上下文深度以及密度效率比率，
 * 量化分析调用图的数据分布特征和结构优化程度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、relationTotalSize（关系总规模）、contextDepth（上下文深度）和densityEfficiencyMetric（密度效率比率）
from int callFactCount, int relationTotalSize, int contextDepth, float densityEfficiencyMetric
where
  // 提取调用关系基础数据：收集所有调用节点、目标函数及其上下文
  exists(ControlFlowNode callerNode, CallableValue calledFunction, PointsToContext callContext |
    callerNode = calledFunction.getACall(callContext) and
    contextDepth = callContext.getDepth() and
    // 基于基础数据计算调用事实总数：统计(callerNode, calledFunction)对的数量
    callFactCount =
      strictcount(ControlFlowNode node, CallableValue func |
        exists(PointsToContext ctx |
          node = func.getACall(ctx)
        )
      ) and
    // 基于基础数据计算关系总规模：统计(callerNode, calledFunction, callContext)三元组的数量
    relationTotalSize =
      strictcount(ControlFlowNode node, CallableValue func, PointsToContext ctx |
        node = func.getACall(ctx)
      ) and
    // 计算密度效率比率：调用事实数占关系总数的百分比
    densityEfficiencyMetric = 100.0 * callFactCount / relationTotalSize
  )
select contextDepth, callFactCount, relationTotalSize, densityEfficiencyMetric // 返回上下文深度、调用事实总数、关系总规模和密度效率比率