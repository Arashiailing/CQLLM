/**
 * 指针分析压缩性能评估：该查询计算在不同上下文深度下，
 * 唯一指针事实与总指针关系数量的比率，用于评估压缩算法的效率。
 * 比率越高表示压缩效果越好。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：唯一事实数、总关系数、上下文深度和压缩效率比率
from int distinctFactsCount, int totalRelationsCount, int contextDepth, float compressionEfficiency
where
  // 计算唯一指针事实数量：统计不同(源节点, 目标对象, 目标类)的组合数
  distinctFactsCount =
    strictcount(ControlFlowNode sourceNode, Object targetObject, ClassObject targetClass |
      exists(PointsToContext context |
        // 检查在特定上下文中，源节点指向目标对象，且该对象属于指定类
        PointsTo::points_to(sourceNode, context, targetObject, targetClass, _) and
        contextDepth = context.getDepth()
      )
    ) and
  // 计算总指针关系数量：统计所有完整的指向关系元组
  totalRelationsCount =
    strictcount(ControlFlowNode sourceNode, Object targetObject, ClassObject targetClass, 
      PointsToContext context, ControlFlowNode originFlowNode |
      // 确认完整的指向关系，包括源节点信息
      PointsTo::points_to(sourceNode, context, targetObject, targetClass, originFlowNode) and
      contextDepth = context.getDepth()
    ) and
  // 计算压缩效率：唯一事实占总关系的百分比
  compressionEfficiency = 100.0 * distinctFactsCount / totalRelationsCount
// 输出结果：上下文深度、唯一事实数量、总关系数量和压缩效率比率
select contextDepth, distinctFactsCount, totalRelationsCount, compressionEfficiency