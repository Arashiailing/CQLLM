/**
 * 本查询用于分析调用图的性能特征，包括：
 * - 统计调用图中的事实总数（不同调用节点与被调用函数的唯一组合数）
 * - 计算调用图关系的总体大小（考虑上下文信息的完整调用关系数）
 * - 评估调用图压缩效率（事实总数与关系大小的比率，以百分比表示）
 * 所有指标均按上下文深度进行分组计算
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：overallFactsCount（事实总数）、relationSize（关系大小）、contextDepth（上下文深度）和efficiencyRatio（效率比率）
from int overallFactsCount, int relationSize, int contextDepth, float efficiencyRatio
where
  // 计算调用图中的事实总数：统计唯一的调用节点与被调用函数组合数量
  overallFactsCount =
    strictcount(ControlFlowNode callNode, CallableValue calledFunc |
      exists(PointsToContext context |
        callNode = calledFunc.getACall(context) and // 获取函数在特定上下文中的调用节点
        contextDepth = context.getDepth() // 记录当前上下文的深度
      )
    ) and
  // 计算调用图关系的总体大小：统计包含上下文信息的完整调用关系数量
  relationSize =
    strictcount(ControlFlowNode callNode, CallableValue calledFunc, PointsToContext context |
      callNode = calledFunc.getACall(context) and // 获取函数在特定上下文中的调用节点
      contextDepth = context.getDepth() // 确保使用相同深度的上下文
    ) and
  // 计算调用图的压缩效率：将事实总数与关系大小的比率转换为百分比
  efficiencyRatio = 100.0 * overallFactsCount / relationSize
select contextDepth, overallFactsCount, relationSize, efficiencyRatio // 返回按上下文深度分组的分析结果