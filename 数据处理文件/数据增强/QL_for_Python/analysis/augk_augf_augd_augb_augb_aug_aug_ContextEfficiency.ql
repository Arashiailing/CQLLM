/**
 * 指针分析压缩性能评估：本查询通过分析不同上下文深度级别中唯一事实数量
 * 与总关系规模的比例，来评估指针分析数据结构的压缩效率和算法性能。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明输出变量：唯一事实计数、关系总数、上下文深度和压缩比率
from int uniqueFactsCount, int totalRelationsCount, int contextDepth, float compressionRatio
where
  // 计算唯一事实数量：统计不同的(控制流节点, 指向对象, 目标类)三元组数量
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass |
      exists(PointsToContext context |
        // 验证在指定上下文中，控制流节点指向目标对象，且该对象是目标类的实例
        PointsTo::points_to(flowNode, context, targetObject, targetClass, _) and
        contextDepth = context.getDepth()
      )
    ) and
  // 计算关系总数：统计包含完整上下文和源节点信息的所有指向关系
  totalRelationsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass, 
      PointsToContext context, ControlFlowNode sourceNode |
      // 验证完整的指向关系，包括源控制流节点信息
      PointsTo::points_to(flowNode, context, targetObject, targetClass, sourceNode) and
      contextDepth = context.getDepth()
    ) and
  // 计算压缩效率比率：唯一事实数量占总关系数量的百分比
  compressionRatio = 100.0 * uniqueFactsCount / totalRelationsCount
// 输出分析结果：上下文深度、唯一事实计数、关系总数和压缩效率比率
select contextDepth, uniqueFactsCount, totalRelationsCount, compressionRatio