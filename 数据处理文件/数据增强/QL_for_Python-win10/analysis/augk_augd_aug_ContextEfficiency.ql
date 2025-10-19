/**
 * 指向关系压缩效率分析：量化唯一事实数量与关系总规模，
 * 计算不同上下文深度下的压缩效率指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、关系总规模、上下文深度和压缩效率
from int distinctFactsCount, int totalRelationsCount, int contextDepth, float compressionRatio
where
  // 计算唯一事实计数：统计不同的(控制流节点, 目标对象, 类对象)三元组
  distinctFactsCount =
    strictcount(ControlFlowNode controlFlowNode, Object targetObject, ClassObject classObject |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类对象的实例
        PointsTo::points_to(controlFlowNode, ctx, targetObject, classObject, _) and
        contextDepth = ctx.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源节点)五元组
  totalRelationsCount =
    strictcount(ControlFlowNode controlFlowNode, Object targetObject, ClassObject classObject, 
      PointsToContext ctx, ControlFlowNode originNode |
      // 验证在指定上下文中，控制流节点指向目标对象，且该对象是类对象的实例，并记录源节点
      PointsTo::points_to(controlFlowNode, ctx, targetObject, classObject, originNode) and
      contextDepth = ctx.getDepth()
    ) and
  // 计算压缩效率：唯一事实计数与关系总规模的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsCount
// 输出结果：上下文深度、唯一事实计数、关系总规模和压缩效率
select contextDepth, distinctFactsCount, totalRelationsCount, compressionRatio