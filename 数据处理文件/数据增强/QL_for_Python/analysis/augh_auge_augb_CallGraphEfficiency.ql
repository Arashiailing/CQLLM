/**
 * 调用图复用效率分析器：评估调用图中节点在不同上下文中的复用情况。
 * 该查询通过计算相同调用在不同上下文中的重复使用率来量化调用图的压缩特性。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出结果包含：上下文深度(contextDepth)、调用事实总数(callFactsCount)、
// 关系总规模(relationTotalSize)和调用复用效率(callReuseEfficiency)
from int contextDepth, int callFactsCount, int relationTotalSize, float callReuseEfficiency
where
  // 首先确定分析的上下文深度，并基于此深度计算调用图的关键指标
  exists(PointsToContext sampleContext |
    contextDepth = sampleContext.getDepth() and // 获取当前分析的上下文深度
    
    // 计算调用事实总数：统计不同(ControlFlowNode, CallableValue)组合的数量
    // 这表示不考虑上下文信息时的调用关系数量
    callFactsCount = strictcount(ControlFlowNode callerNode, CallableValue targetFunction |
      exists(PointsToContext callContext |
        callerNode = targetFunction.getACall(callContext) and // 确认调用关系存在
        callContext.getDepth() = contextDepth // 限定在相同深度范围内统计
      )
    ) and
    
    // 计算关系总规模：统计包含上下文信息的完整调用关系数量
    // 即(ControlFlowNode, CallableValue, PointsToContext)三元组的总数
    relationTotalSize = strictcount(ControlFlowNode callerNode, CallableValue targetFunction, PointsToContext callContext |
      callerNode = targetFunction.getACall(callContext) and // 确认调用关系存在
      callContext.getDepth() = contextDepth // 限定在相同深度范围内统计
    ) and
    
    // 计算调用复用效率：调用事实总数与关系总规模的比率，以百分比表示
    // 较高的值表明相同调用在不同上下文中被高度复用，体现了调用图的压缩效率
    callReuseEfficiency = 100.0 * callFactsCount / relationTotalSize
  )
select contextDepth, callFactsCount, relationTotalSize, callReuseEfficiency // 返回分析结果