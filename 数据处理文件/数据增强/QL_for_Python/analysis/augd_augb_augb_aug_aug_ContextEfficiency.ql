/**
 * 指针分析压缩效率评估：该查询通过测量不同上下文深度下唯一事实数量与
 * 总关系规模的比率，评估指针分析数据结构的压缩性能和算法有效性。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义结果变量：唯一事实计数、关系总数、上下文深度和压缩效率
from int uniqueFactsCount, int totalRelationsCount, int contextDepth, float compressionEfficiency
where
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 目标类)组合
  uniqueFactsCount =
    strictcount(ControlFlowNode cfgNode, Object targetObject, ClassObject targetClass |
      exists(PointsToContext contextInfo |
        // 验证在特定上下文中，控制流节点指向目标对象，且该对象属于指定类
        PointsTo::points_to(cfgNode, contextInfo, targetObject, targetClass, _) and
        contextDepth = contextInfo.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有完整的指向关系元组
  totalRelationsCount =
    strictcount(ControlFlowNode cfgNode, Object targetObject, ClassObject targetClass, 
      PointsToContext contextInfo, ControlFlowNode sourceNode |
      // 确认完整的指向关系，包括源节点信息
      PointsTo::points_to(cfgNode, contextInfo, targetObject, targetClass, sourceNode) and
      contextDepth = contextInfo.getDepth()
    ) and
  // 计算压缩效率比率：唯一事实占总关系的百分比
  compressionEfficiency = 100.0 * uniqueFactsCount / totalRelationsCount
// 输出分析结果：上下文深度、唯一事实数量、关系总数和压缩效率比率
select contextDepth, uniqueFactsCount, totalRelationsCount, compressionEfficiency