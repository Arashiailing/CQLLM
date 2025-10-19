/**
 * 调用图结构分析：评估调用图的紧凑性与效率指标。
 * 本查询通过计算调用事实总数、关系规模、上下文深度以及密度指标，
 * 量化分析调用图的数据压缩效率和结构优化空间，为代码重构决策提供数据支持。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出变量定义：totalCallFacts（调用事实总数）、totalCallRelations（关系总规模）、
// contextDepth（上下文深度）和densityMetric（密度指标）
from int totalCallFacts, int totalCallRelations, int contextDepth, float densityMetric
where
  // 提取上下文深度信息用于密度计算
  exists(int contextDepthValue |
    // 计算调用事实总数：统计所有(调用节点, 被调用函数)二元组的数量
    totalCallFacts =
      strictcount(ControlFlowNode callingNode, CallableValue calledFunction |
        exists(PointsToContext invocationContext |
          callingNode = calledFunction.getACall(invocationContext) and // 获取调用节点与被调用函数关系
          contextDepthValue = invocationContext.getDepth() // 记录调用上下文深度
        )
      ) and
    // 计算调用图关系总规模：统计所有(调用节点, 被调用函数, 调用上下文)三元组的数量
    totalCallRelations =
      strictcount(ControlFlowNode callingNode, CallableValue calledFunction, PointsToContext invocationContext |
        callingNode = calledFunction.getACall(invocationContext) and // 获取完整调用关系三元组
        contextDepthValue = invocationContext.getDepth() and // 保持上下文深度一致性
        contextDepth = contextDepthValue // 将深度值传递给输出变量
      ) and
    // 计算密度指标：将事实总数转换为相对于关系总规模的百分比
    // 该指标反映调用图的结构紧凑度，数值越高表示信息密度越大
    densityMetric = 100.0 * totalCallFacts / totalCallRelations
  )
select contextDepth, totalCallFacts, totalCallRelations, densityMetric // 返回分析结果：上下文深度、调用事实数、关系规模和密度指标