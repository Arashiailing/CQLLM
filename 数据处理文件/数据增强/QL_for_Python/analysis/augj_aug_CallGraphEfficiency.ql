/**
 * 调用图紧凑性分析：评估调用图的统计特性与效率
 * 该查询通过分析调用图的事实数量、关系规模、上下文深度及其紧凑性比率，
 * 来量化调用图的结构效率。紧凑性比率越高，表示调用图结构越优化。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义分析结果变量：totalFacts（调用事实总数）、totalRelations（关系总数）、
// maxContextDepth（最大上下文深度）和compactnessRatio（紧凑性比率）
from int totalFacts, int totalRelations, int maxContextDepth, float compactnessRatio
where
  // 提取公共查询条件，避免重复计算
  exists(ControlFlowNode callNode, CallableValue callable, PointsToContext analysisContext |
    callNode = callable.getACall(analysisContext) and
    maxContextDepth = analysisContext.getDepth() and
    // 计算调用图中的事实总数：统计所有(ControlFlowNode, CallableValue)对
    totalFacts = strictcount(ControlFlowNode cn, CallableValue cv |
      exists(PointsToContext ctx |
        cn = cv.getACall(ctx)
      )
    ) and
    // 计算调用图关系的总大小：统计所有(ControlFlowNode, CallableValue, PointsToContext)三元组
    totalRelations = strictcount(ControlFlowNode cn, CallableValue cv, PointsToContext ctx |
      cn = cv.getACall(ctx)
    ) and
    // 计算紧凑性比率：调用事实数与关系总数的百分比，衡量调用图的结构效率
    compactnessRatio = 100.0 * totalFacts / totalRelations
  )
select maxContextDepth, totalFacts, totalRelations, compactnessRatio // 输出分析结果