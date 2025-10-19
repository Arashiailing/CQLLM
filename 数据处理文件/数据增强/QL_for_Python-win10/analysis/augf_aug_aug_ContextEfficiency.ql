/**
 * 分析指向关系数据结构的压缩性能：通过测量不同上下文深度下的
 * 去重事实数量与总关系规模的比例，评估压缩算法的效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：去重事实计数、关系总规模、上下文深度和压缩比率
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 计算去重事实数量：统计唯一的(控制流节点, 目标对象, 对象类)三元组
  distinctFactsCount =
    strictcount(ControlFlowNode controlFlowNode, Object targetObject, ClassObject objectClass |
      exists(PointsToContext pointsToContext |
        // 检查在给定上下文中，控制流节点是否指向特定对象，且该对象属于特定类
        PointsTo::points_to(controlFlowNode, pointsToContext, targetObject, objectClass, _) and
        contextDepth = pointsToContext.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 对象类, 上下文, 源节点)五元组
  totalRelationsSize =
    strictcount(ControlFlowNode controlFlowNode, Object targetObject, ClassObject objectClass, 
      PointsToContext pointsToContext, ControlFlowNode sourceNode |
      // 验证完整的指向关系，包括源节点信息
      PointsTo::points_to(controlFlowNode, pointsToContext, targetObject, objectClass, sourceNode) and
      contextDepth = pointsToContext.getDepth()
    ) and
  // 计算压缩比率：去重事实数量占关系总规模的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize
// 输出结果：上下文深度、去重事实数量、关系总规模和压缩比率
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio