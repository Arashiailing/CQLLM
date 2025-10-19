/**
 * 评估指针分析数据结构的压缩性能指标：通过分析不同上下文深度下，
 * 唯一事实数量与总关系规模的比率，量化压缩算法的有效性。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：唯一事实计数、关系总数、上下文深度和压缩比率
from int uniqueFactCount, int totalRelationCount, int ctxDepth, float compressionRatio
where
  // 统计唯一事实数量：计算不同的(控制流节点, 目标对象, 目标类)组合
  uniqueFactCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject pointedClass |
      exists(PointsToContext contextInfo |
        // 验证在特定上下文中，控制流节点指向目标对象，且该对象属于指定类
        PointsTo::points_to(flowNode, contextInfo, pointedObject, pointedClass, _) and
        ctxDepth = contextInfo.getDepth()
      )
    ) and
  // 统计关系总规模：计算所有完整的指向关系元组
  totalRelationCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject pointedClass, 
      PointsToContext contextInfo, ControlFlowNode originNode |
      // 确认完整的指向关系，包括源节点信息
      PointsTo::points_to(flowNode, contextInfo, pointedObject, pointedClass, originNode) and
      ctxDepth = contextInfo.getDepth()
    ) and
  // 计算压缩效率比率：唯一事实占总关系的百分比
  compressionRatio = 100.0 * uniqueFactCount / totalRelationCount
// 输出分析结果：上下文深度、唯一事实数量、关系总数和压缩效率比率
select ctxDepth, uniqueFactCount, totalRelationCount, compressionRatio