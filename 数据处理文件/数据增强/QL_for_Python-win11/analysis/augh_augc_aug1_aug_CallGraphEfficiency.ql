/**
 * 调用图结构分析：量化评估调用图的密度与效率特性。
 * 
 * 本查询通过分析调用事实数量、关系规模、上下文深度以及密度指标，
 * 来综合评估调用图的数据密度和结构效率。
 * 
 * 输出结果：
 * - callContextDepth: 调用上下文的深度
 * - callFactCount: 调用事实总数，即(调用点, 被调用函数)对的数量
 * - callRelationCount: 关系总规模，即(调用点, 被调用函数, 调用上下文)三元组的数量
 * - callDensityMetric: 密度指标，表示调用事实总数相对于关系总规模的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：调用事实总数、关系总规模、上下文深度和密度指标
from int callFactCount, int callRelationCount, int callContextDepth, float callDensityMetric
where
  // 确定上下文深度：从调用图中获取一个调用上下文的深度
  exists(PointsToContext invocationContext |
    callContextDepth = invocationContext.getDepth() and
    exists(ControlFlowNode callPoint, CallableValue calledFunction |
      callPoint = calledFunction.getACall(invocationContext) // 确保该上下文确实被使用
    )
  ) and
  
  // 计算调用图中的事实总数：统计所有(调用点, 被调用函数)对的数量
  // 这些对具有相同的上下文深度
  callFactCount = strictcount(ControlFlowNode cp, CallableValue cf |
    exists(PointsToContext ic |
      cp = cf.getACall(ic) and // 调用点cp是被调用函数cf在上下文ic中的一个调用
      callContextDepth = ic.getDepth() // 上下文深度与当前查询的深度相同
    )
  ) and
  
  // 计算调用图关系的总规模：统计所有(调用点, 被调用函数, 调用上下文)三元组的数量
  // 这些三元组具有相同的上下文深度
  callRelationCount = strictcount(ControlFlowNode cp, CallableValue cf, PointsToContext ic |
    cp = cf.getACall(ic) and // 调用点cp是被调用函数cf在上下文ic中的一个调用
    callContextDepth = ic.getDepth() // 上下文深度与当前查询的深度相同
  ) and
  
  // 计算密度指标：将事实总数转换为相对于关系总规模的百分比
  // 这个指标反映了调用图的紧凑程度：值越高，表示每个上下文深度上的调用关系越集中
  callDensityMetric = 100.0 * callFactCount / callRelationCount

select callContextDepth, callFactCount, callRelationCount, callDensityMetric // 返回上下文深度、调用事实总数、关系总规模和密度指标