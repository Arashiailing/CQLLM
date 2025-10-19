/**
 * 分析调用图的统计特性，包括事实数量、关系大小、上下文深度及其效率比率。
 * 该查询评估调用图的紧凑性，通过计算事实数与关系大小的比率来衡量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：factCount（事实总数）、relationSize（关系总大小）、contextDepth（上下文深度）和efficiencyRatio（效率比率）
from int factCount, int relationSize, int contextDepth, float efficiencyRatio
where
  // 计算调用图中的事实总数：统计所有(ControlFlowNode, CallableValue)对的数量
  factCount =
    strictcount(ControlFlowNode callNode, CallableValue callable |
      exists(PointsToContext analysisContext |
        callNode = callable.getACall(analysisContext) and // 获取callable在analysisContext中的调用节点callNode
        contextDepth = analysisContext.getDepth() // 记录analysisContext的深度
      )
    ) and
  // 计算调用图关系的总大小：统计所有(ControlFlowNode, CallableValue, PointsToContext)三元组的数量
  relationSize =
    strictcount(ControlFlowNode callNode, CallableValue callable, PointsToContext analysisContext |
      callNode = callable.getACall(analysisContext) and // 获取callable在analysisContext中的调用节点callNode
      contextDepth = analysisContext.getDepth() // 记录analysisContext的深度
    ) and
  // 计算效率比率：将事实总数转换为相对于关系总大小的百分比
  efficiencyRatio = 100.0 * factCount / relationSize
select contextDepth, factCount, relationSize, efficiencyRatio // 返回上下文深度、事实总数、关系总大小和效率比率