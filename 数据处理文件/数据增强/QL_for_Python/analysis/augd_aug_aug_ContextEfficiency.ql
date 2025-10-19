/**
 * 分析指向关系数据结构的压缩效率：通过计算不同上下文深度下的
 * 唯一事实数量与关系总规模，评估数据压缩的性能指标。
 * 
 * 该查询计算以下指标：
 * - 唯一事实数量：不同(控制流节点, 指向对象, 对象类)组合的数量
 * - 关系总规模：包含上下文和源节点信息的完整关系数量
 * - 压缩效率：唯一事实数量占关系总规模的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、关系规模、上下文深度和压缩效率指标
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 基本条件：存在指向关系，并确定上下文深度
  exists(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject objectClass, PointsToContext pointsToContext |
    PointsTo::points_to(controlFlowNode, pointsToContext, pointedObject, objectClass, _) and
    contextDepth = pointsToContext.getDepth()
  ) and
  // 计算唯一事实数量：统计不同的(控制流节点, 指向对象, 对象类)三元组
  distinctFactsCount =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject objectClass |
      // 筛选指定上下文深度的指向关系
      exists(PointsToContext pointsToContext |
        PointsTo::points_to(controlFlowNode, pointsToContext, pointedObject, objectClass, _) and
        pointsToContext.getDepth() = contextDepth
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 指向对象, 对象类, 上下文, 源节点)五元组
  totalRelationsSize =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject objectClass, 
      PointsToContext pointsToContext, ControlFlowNode originNode |
      // 筛选指定上下文深度的完整指向关系
      PointsTo::points_to(controlFlowNode, pointsToContext, pointedObject, objectClass, originNode) and
      pointsToContext.getDepth() = contextDepth
    ) and
  // 计算压缩效率：唯一事实数量占关系总规模的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio