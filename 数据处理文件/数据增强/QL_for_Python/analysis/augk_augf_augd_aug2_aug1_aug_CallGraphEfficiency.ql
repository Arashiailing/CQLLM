/**
 * Python调用图结构效率评估：分析代码中调用关系的紧凑度与优化空间。
 * 本查询通过统计调用事实数量、上下文相关关系规模、调用深度并计算密度指标，
 * 量化调用图的结构效率，为代码重构和性能优化提供数据参考。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出指标：callFactCount（调用事实数量）、callRelationCount（上下文相关关系数量）、
// ctxDepth（调用上下文深度）和densityMetric（调用图密度百分比）
from int callFactCount, int callRelationCount, int ctxDepth, float densityMetric
where
  // 分析调用图结构并计算各项指标
  exists(int measuredDepth |
    // 步骤1：计算调用事实数量 - 统计所有(调用点, 目标函数)二元组
    // 该指标反映不考虑上下文信息时的基本调用关系数量
    callFactCount = strictcount(ControlFlowNode callSite, CallableValue targetFunction |
      exists(PointsToContext invocationContext |
        callSite = targetFunction.getACall(invocationContext) and // 获取调用点在特定上下文中调用的函数
        measuredDepth = invocationContext.getDepth() // 记录调用上下文深度
      )
    ) and
    
    // 步骤2：计算上下文相关关系数量 - 统计所有(调用点, 目标函数, 调用上下文)三元组
    // 该指标反映考虑上下文信息时的完整调用关系数量
    callRelationCount = strictcount(ControlFlowNode callSite, CallableValue targetFunction, PointsToContext invocationContext |
      callSite = targetFunction.getACall(invocationContext) and // 确保使用相同的调用关系
      measuredDepth = invocationContext.getDepth() // 保持深度一致性
    ) and
    
    // 步骤3：设置调用上下文深度值
    ctxDepth = measuredDepth
  ) and
  
  // 步骤4：计算调用图密度指标 - 将调用事实数量转换为相对于上下文相关关系的百分比
  // 该指标反映调用图的紧凑程度，值越高表示结构越紧凑，优化空间越小
  // 密度 = (调用事实数量 / 上下文相关关系数量) * 100%
  densityMetric = 100.0 * callFactCount / callRelationCount
select ctxDepth, callFactCount, callRelationCount, densityMetric // 返回调用上下文深度、调用事实数量、上下文相关关系数量和调用图密度指标