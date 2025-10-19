/**
 * 评估调用图的结构特征，包括实际调用点数量、关联关系总数、上下文分析深度及其紧凑性指标。
 * 该查询通过计算实际调用点数量与关联关系总数的比率来评估调用图的密度和效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：totalFacts（调用点总数）、totalRelations（关系总数）、analysisDepth（分析深度）和compactnessMetric（紧凑性指标）
from int totalFacts, int totalRelations, int analysisDepth, float compactnessMetric
where
  // 统计调用图中所有唯一调用点的数量：计算所有(ControlFlowNode, CallableValue)组合
  totalFacts =
    strictcount(ControlFlowNode invocationSite, CallableValue targetFunction |
      exists(PointsToContext contextInfo |
        invocationSite = targetFunction.getACall(contextInfo) and // 获取targetFunction在contextInfo中的调用点invocationSite
        analysisDepth = contextInfo.getDepth() // 提取contextInfo的分析深度
      )
    ) and
  // 计算调用图关联关系的总量：统计所有(ControlFlowNode, CallableValue, PointsToContext)组合的数量
  totalRelations =
    strictcount(ControlFlowNode invocationSite, CallableValue targetFunction, PointsToContext contextInfo |
      invocationSite = targetFunction.getACall(contextInfo) and // 获取targetFunction在contextInfo中的调用点invocationSite
      analysisDepth = contextInfo.getDepth() // 提取contextInfo的分析深度
    ) and
  // 计算紧凑性指标：将调用点总数转换为相对于关系总数的百分比
  compactnessMetric = 100.0 * totalFacts / totalRelations
select analysisDepth, totalFacts, totalRelations, compactnessMetric // 返回分析深度、调用点总数、关系总数和紧凑性指标