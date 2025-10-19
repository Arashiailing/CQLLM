/**
 * 评估指向关系数据结构的压缩效率：通过计算不同上下文深度下的
 * 唯一事实数量与总关系规模的比例，分析压缩算法的性能表现。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、关系总计数、深度级别和效率比率
from int uniqueFactsCount, int totalRelationsCount, int depthLevel, float efficiencyRatio
where
  // 计算唯一事实数量：统计唯一的(流节点, 指向对象, 对象类)三元组
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject objectClass |
      exists(PointsToContext context |
        // 检查在给定上下文中，流节点是否指向特定对象，且该对象属于特定类
        PointsTo::points_to(flowNode, context, pointedObject, objectClass, _) and
        depthLevel = context.getDepth()
      )
    ) and
  // 计算关系总计数：统计所有(流节点, 指向对象, 对象类, 上下文, 源节点)五元组
  totalRelationsCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject objectClass, 
      PointsToContext context, ControlFlowNode originNode |
      // 验证完整的指向关系，包括源节点信息
      PointsTo::points_to(flowNode, context, pointedObject, objectClass, originNode) and
      depthLevel = context.getDepth()
    ) and
  // 计算效率比率：唯一事实数量占关系总计数的百分比
  efficiencyRatio = 100.0 * uniqueFactsCount / totalRelationsCount
// 输出结果：深度级别、唯一事实数量、关系总计数和效率比率
select depthLevel, uniqueFactsCount, totalRelationsCount, efficiencyRatio