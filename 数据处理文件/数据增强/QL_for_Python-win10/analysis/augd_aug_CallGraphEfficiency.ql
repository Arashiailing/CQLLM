/**
 * 深度分析Python调用图的统计特性，包括事实总量、关系规模、上下文深度及其效率指标。
 * 通过计算事实数量与关系大小的比率，评估调用图的紧凑性，为代码优化提供数据支持。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：totalFacts（事实总量）、totalRelations（关系规模）、contextDepth（上下文深度）和efficiencyMetric（效率指标）
from int totalFacts, int totalRelations, int contextDepth, float efficiencyMetric
where
  // 计算调用图中的事实总量：统计所有(ControlFlowNode, CallableValue)对的数量
  totalFacts =
    strictcount(ControlFlowNode callNode, CallableValue callable |
      exists(PointsToContext analysisContext |
        callNode = callable.getACall(analysisContext) and // 获取callable在analysisContext中的调用节点callNode
        contextDepth = analysisContext.getDepth() // 记录analysisContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(ControlFlowNode, CallableValue, PointsToContext)三元组的数量
  totalRelations =
    strictcount(ControlFlowNode callNode, CallableValue callable, PointsToContext analysisContext |
      callNode = callable.getACall(analysisContext) and // 获取callable在analysisContext中的调用节点callNode
      contextDepth = analysisContext.getDepth() // 记录analysisContext的深度
    ) and
  // 计算效率指标：将事实总量转换为相对于关系总规模的百分比
  efficiencyMetric = 100.0 * totalFacts / totalRelations
select contextDepth, totalFacts, totalRelations, efficiencyMetric // 返回上下文深度、事实总量、关系总规模和效率指标