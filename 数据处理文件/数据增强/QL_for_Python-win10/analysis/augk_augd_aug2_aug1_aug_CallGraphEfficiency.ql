/**
 * 调用图结构效率分析：评估Python代码中调用图的紧凑性和优化空间。
 * 此查询通过统计调用事实数量、关系规模、上下文深度并计算密度指标，
 * 量化调用图的结构效率和数据压缩率，为代码重构提供量化参考。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：invocationFactCount（调用事实总数）、invocationRelationCount（关系总规模）、
// contextDepth（上下文深度）和invocationGraphDensity（调用图密度指标）
from int invocationFactCount, int invocationRelationCount, int contextDepth, float invocationGraphDensity
where
  // 获取调用上下文深度信息
  exists(int contextDepthValue |
    // 设置上下文深度值
    contextDepth = contextDepthValue and
    // 统计调用事实总数：计算所有(调用节点, 被调用函数)二元组的数量
    invocationFactCount =
      strictcount(ControlFlowNode callerNode, CallableValue calleeFunction |
        exists(PointsToContext callContext |
          callerNode = calleeFunction.getACall(callContext) and // 获取被调用函数在调用上下文中的调用节点
          contextDepthValue = callContext.getDepth() // 记录调用上下文的深度
        )
      ) and
    // 统计调用图关系总规模：计算所有(调用节点, 被调用函数, 调用上下文)三元组的数量
    invocationRelationCount =
      strictcount(ControlFlowNode callerNode, CallableValue calleeFunction, PointsToContext callContext |
        callerNode = calleeFunction.getACall(callContext) and // 获取被调用函数在调用上下文中的调用节点
        contextDepthValue = callContext.getDepth() // 确保使用相同的上下文深度
      )
  ) and
  // 计算调用图密度指标：将调用事实总数转换为相对于关系总规模的百分比密度
  // 该指标反映调用图的紧凑程度，值越高表示结构越紧凑，优化空间越小
  invocationGraphDensity = 100.0 * invocationFactCount / invocationRelationCount
select contextDepth, invocationFactCount, invocationRelationCount, invocationGraphDensity // 返回上下文深度、调用事实总数、关系总规模和调用图密度指标