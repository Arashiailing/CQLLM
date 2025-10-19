/**
 * 本查询分析Python调用图的统计特性，包括：
 * - 事实总数：表示调用图中不同调用点与被调用函数的唯一组合数量
 * - 关系总大小：表示考虑上下文后的完整调用关系数量
 * - 效率比率：事实总数与关系总大小的百分比，反映上下文信息的密度
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：factCount（事实总数）、relationSize（关系总大小）、contextDepth（上下文深度）和efficiencyRatio（效率比率）
from int factCount, int relationSize, int contextDepth, float efficiencyRatio
where
  // 计算调用图中的事实总数，统计唯一的调用点与被调用函数对
  factCount =
    strictcount(ControlFlowNode callSite, CallableValue targetFunction |
      exists(PointsToContext analysisContext |
        callSite = targetFunction.getACall(analysisContext) and // 获取函数在特定上下文中的调用点
        contextDepth = analysisContext.getDepth() // 记录当前分析的上下文深度
      )
    ) and
  // 计算调用图关系的总大小，统计包含上下文信息的完整调用关系
  relationSize =
    strictcount(ControlFlowNode callSite, CallableValue targetFunction, PointsToContext analysisContext |
      callSite = targetFunction.getACall(analysisContext) and // 获取函数在特定上下文中的调用点
      contextDepth = analysisContext.getDepth() // 记录当前分析的上下文深度
    ) and
  // 计算调用图的效率比率，表示事实密度（百分比形式）
  efficiencyRatio = 100.0 * factCount / relationSize
select contextDepth, factCount, relationSize, efficiencyRatio // 输出结果：上下文深度、事实总数、关系总大小和效率比率