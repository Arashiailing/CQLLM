/**
 * 分析指向关系数据结构的压缩效率指标：通过计算不同上下文深度下
 * 唯一事实数量与总关系规模的比率，评估数据压缩性能表现。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出参数：唯一事实计数、关系总规模、上下文深度和压缩效率比率
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 计算不同上下文深度下的唯一事实数量：统计不重复的(控制流节点, 目标对象, 对象类型)三元组
  distinctFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject objectType |
      exists(PointsToContext pointsToContext |
        // 验证在特定上下文中，控制流节点指向目标对象，且该对象属于指定类型
        PointsTo::points_to(flowNode, pointsToContext, targetObject, objectType, _) and
        contextDepth = pointsToContext.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 对象类型, 上下文, 源节点)五元组数量
  totalRelationsSize =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject objectType, 
      PointsToContext pointsToContext, ControlFlowNode sourceNode |
      // 确认完整的指向关系，包括源节点信息
      PointsTo::points_to(flowNode, pointsToContext, targetObject, objectType, sourceNode) and
      contextDepth = pointsToContext.getDepth()
    ) and
  // 计算压缩效率比率：唯一事实数量占总关系规模的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize
// 输出分析结果：上下文深度、唯一事实数量、关系总规模和压缩效率比率
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio