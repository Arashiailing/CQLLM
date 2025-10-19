/**
 * 评估指向关系数据结构的压缩性能：通过测量不同上下文深度下的
 * 唯一事实数量与总关系规模，计算数据压缩的有效性。
 * 
 * 该查询计算以下性能指标：
 * - 唯一事实数量：不同(控制流节点, 目标对象, 对象类)组合的计数
 * - 总关系规模：包含上下文和源节点信息的完整关系数量
 * - 压缩效率：唯一事实数量占总关系规模的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询输出变量：唯一事实计数、关系总数、上下文深度和压缩效率
from int uniqueFactsCount, int totalRelationCount, int ctxDepth, float compressionEfficiency
where
  // 基础条件：确保存在指向关系并确定上下文深度
  exists(ControlFlowNode cfNode, Object targetObject, ClassObject objClass, PointsToContext ptContext |
    PointsTo::points_to(cfNode, ptContext, targetObject, objClass, _) and
    ctxDepth = ptContext.getDepth()
  ) and
  // 计算唯一事实数量：统计不同(控制流节点, 目标对象, 对象类)三元组的数量
  uniqueFactsCount =
    strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject objClass |
      // 筛选特定上下文深度的指向关系
      exists(PointsToContext ptContext |
        PointsTo::points_to(cfNode, ptContext, targetObject, objClass, _) and
        ptContext.getDepth() = ctxDepth
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 对象类, 上下文, 源节点)五元组的数量
  totalRelationCount =
    strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject objClass, 
      PointsToContext ptContext, ControlFlowNode sourceNode |
      // 筛选特定上下文深度的完整指向关系
      PointsTo::points_to(cfNode, ptContext, targetObject, objClass, sourceNode) and
      ptContext.getDepth() = ctxDepth
    ) and
  // 计算压缩效率：唯一事实数量占总关系规模的百分比
  compressionEfficiency = 100.0 * uniqueFactsCount / totalRelationCount
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select ctxDepth, uniqueFactsCount, totalRelationCount, compressionEfficiency