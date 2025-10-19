/**
 * 调用图结构效率分析：评估Python代码中调用图的紧凑性和优化空间。
 * 此查询通过统计调用事实数量、关系规模、上下文深度并计算密度指标，
 * 量化调用图的结构效率和数据压缩率，为代码重构提供量化参考。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、callRelationCount（关系总规模）、
// callContextDepth（上下文深度）和callGraphDensity（调用图密度指标）
from int callFactCount, int callRelationCount, int callContextDepth, float callGraphDensity
where
  // 统计调用事实总数和关系规模，同时获取上下文深度信息
  exists(int depth |
    // 计算调用事实总数：统计所有(调用节点, 目标函数)二元组的数量
    callFactCount =
      strictcount(ControlFlowNode invokingNode, CallableValue targetFunction |
        exists(PointsToContext invocationContext |
          invokingNode = targetFunction.getACall(invocationContext) and // 获取目标函数在调用上下文中的调用节点
          depth = invocationContext.getDepth() // 记录调用上下文的深度
        )
      ) and
    // 计算调用图关系总规模：统计所有(调用节点, 目标函数, 调用上下文)三元组的数量
    callRelationCount =
      strictcount(ControlFlowNode invokingNode, CallableValue targetFunction, PointsToContext invocationContext |
        invokingNode = targetFunction.getACall(invocationContext) and // 获取目标函数在调用上下文中的调用节点
        depth = invocationContext.getDepth() // 确保使用相同的上下文深度
      ) and
    // 设置上下文深度值
    callContextDepth = depth
  ) and
  // 计算调用图密度指标：将调用事实总数转换为相对于关系总规模的百分比密度
  // 该指标反映调用图的紧凑程度，值越高表示结构越紧凑，优化空间越小
  callGraphDensity = 100.0 * callFactCount / callRelationCount
select callContextDepth, callFactCount, callRelationCount, callGraphDensity // 返回上下文深度、调用事实总数、关系总规模和调用图密度指标