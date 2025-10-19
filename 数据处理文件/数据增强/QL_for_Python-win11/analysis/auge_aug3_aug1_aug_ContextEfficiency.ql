/**
 * @name 指向关系图压缩效率评估
 * @description 此查询分析指向关系图的压缩效率，通过比较唯一事实数量与关系图总规模，
 *              计算不同上下文深度下的压缩效率百分比，评估数据压缩效果。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总规模、上下文深度和压缩效率
from int uniqueFactsCount, int totalRelationsCount, int ctxDepth, float compressionEfficiency
where
  // 获取当前分析的上下文深度
  exists(PointsToContext ctx | ctxDepth = ctx.getDepth()) and
  (
    // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 类类型)组合
    uniqueFactsCount =
      strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject classType |
        exists(PointsToContext ctx |
          // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类类型的实例
          PointsTo::points_to(controlNode, ctx, targetObject, classType, _) and
          ctx.getDepth() = ctxDepth
        )
      )
  ) and
  (
    // 计算关系总规模：统计所有(控制流节点, 目标对象, 类类型, 上下文, 源控制流节点)组合
    totalRelationsCount =
      strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject classType, 
        PointsToContext ctx, ControlFlowNode sourceControlNode |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类类型的实例，并记录源控制流节点
        PointsTo::points_to(controlNode, ctx, targetObject, classType, sourceControlNode) and
        ctx.getDepth() = ctxDepth
      )
  ) and
  (
    // 计算压缩效率：唯一事实数量占关系总规模的百分比
    compressionEfficiency = 100.0 * uniqueFactsCount / totalRelationsCount
  )
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select ctxDepth, uniqueFactsCount, totalRelationsCount, compressionEfficiency