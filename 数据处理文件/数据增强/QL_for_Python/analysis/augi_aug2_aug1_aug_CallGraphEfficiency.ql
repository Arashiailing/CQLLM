/**
 * 调用图结构密度与效率分析：评估调用图的信息密度和结构优化效率
 * 本查询通过量化调用事实数量、关系规模、上下文深度及密度指标，
 * 分析调用图的数据压缩率和结构效率，为代码结构优化提供量化依据。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、callRelationCount（关系总规模）、
// callContextDepth（上下文深度）和callGraphDensity（调用图密度指标）
from int callFactCount, int callRelationCount, int callContextDepth, float callGraphDensity
where
  // 统计调用事实总数：计算所有(调用节点, 目标函数)二元组的数量
  // 同时获取调用上下文深度信息用于密度分析
  exists(ControlFlowNode invokingNode, CallableValue targetFunction, PointsToContext invocationContext |
    invokingNode = targetFunction.getACall(invocationContext) and
    callContextDepth = invocationContext.getDepth() and
    // 计算调用事实总数（不包含上下文信息的调用关系）
    callFactCount =
      strictcount(ControlFlowNode caller, CallableValue callee |
        exists(PointsToContext ctx | caller = callee.getACall(ctx))
      ) and
    // 计算调用图关系总规模：统计所有(调用节点, 目标函数, 调用上下文)三元组的数量
    callRelationCount =
      strictcount(ControlFlowNode caller, CallableValue callee, PointsToContext ctx |
        caller = callee.getACall(ctx)
      ) and
    // 计算调用图密度指标：将事实总数转换为相对于关系总规模的百分比密度
    // 该指标反映调用图的紧凑程度，值越高表示结构越紧凑，信息密度越大
    callGraphDensity = 100.0 * callFactCount / callRelationCount
  )
select callContextDepth, callFactCount, callRelationCount, callGraphDensity // 返回调用上下文深度、调用事实总数、关系总规模和调用图密度指标