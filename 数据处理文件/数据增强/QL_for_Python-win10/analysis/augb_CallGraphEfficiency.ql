/**
 * 分析调用图的统计特性，包括事实总数、关系总规模以及基于上下文深度的效率评估。
 * 该查询用于衡量调用图的紧凑程度，即相同调用节点在不同上下文中的复用情况。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：factCount（调用事实总数）、relationSize（关系总规模）、contextDepth（上下文深度）和efficiencyRatio（效率比率）
from int factCount, int relationSize, int contextDepth, float efficiencyRatio
where
  // 首先确定上下文深度，并基于此计算调用图的两个关键指标
  exists(PointsToContext ctx |
    contextDepth = ctx.getDepth() and // 获取当前分析的上下文深度
    
    // 计算调用事实总数：统计不同(ControlFlowNode, CallableValue)对的数量
    factCount = strictcount(ControlFlowNode callNode, CallableValue targetFunc |
      exists(PointsToContext analysisCtx |
        callNode = targetFunc.getACall(analysisCtx) and // 确认调用关系
        analysisCtx.getDepth() = contextDepth // 确保在相同深度下计算
      )
    ) and
    
    // 计算关系总规模：统计包含上下文信息的(ControlFlowNode, CallableValue, PointsToContext)三元组数量
    relationSize = strictcount(ControlFlowNode callNode, CallableValue targetFunc, PointsToContext analysisCtx |
      callNode = targetFunc.getACall(analysisCtx) and // 确认调用关系
      analysisCtx.getDepth() = contextDepth // 确保在相同深度下计算
    ) and
    
    // 计算效率比率：调用事实总数与关系总规模的比值，转换为百分比形式
    // 该值越高，表示相同调用在不同上下文中复用程度越高
    efficiencyRatio = 100.0 * factCount / relationSize
  )
select contextDepth, factCount, relationSize, efficiencyRatio // 返回分析结果：上下文深度、调用事实总数、关系总规模和效率比率