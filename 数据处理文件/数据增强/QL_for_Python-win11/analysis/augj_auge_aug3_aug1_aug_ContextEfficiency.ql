/**
 * @name 指向关系图压缩效率评估
 * @description 分析指向关系图的压缩效率，通过比较唯一事实数量与关系图总规模，
 *              计算不同上下文深度下的压缩效率百分比，评估数据压缩效果。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总规模、上下文深度和压缩效率
from int distinctFactsCount, int totalGraphSize, int contextDepth, float efficiencyPercentage
where
  // 获取当前分析的上下文深度
  exists(PointsToContext ctx | contextDepth = ctx.getDepth()) and
  (
    // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 类类型)组合
    distinctFactsCount =
      strictcount(ControlFlowNode node, Object obj, ClassObject cls |
        exists(PointsToContext ctx |
          // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类类型的实例
          PointsTo::points_to(node, ctx, obj, cls, _) and
          ctx.getDepth() = contextDepth
        )
      )
  ) and
  (
    // 计算关系总规模：统计所有(控制流节点, 目标对象, 类类型, 上下文, 源控制流节点)组合
    totalGraphSize =
      strictcount(ControlFlowNode node, Object obj, ClassObject cls, 
        PointsToContext ctx, ControlFlowNode sourceNode |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类类型的实例，并记录源控制流节点
        PointsTo::points_to(node, ctx, obj, cls, sourceNode) and
        ctx.getDepth() = contextDepth
      )
  ) and
  (
    // 计算压缩效率：唯一事实数量占关系总规模的百分比
    efficiencyPercentage = 100.0 * distinctFactsCount / totalGraphSize
  )
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select contextDepth, distinctFactsCount, totalGraphSize, efficiencyPercentage