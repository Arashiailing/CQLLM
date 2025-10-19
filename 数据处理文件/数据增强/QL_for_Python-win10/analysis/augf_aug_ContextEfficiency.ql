/**
 * 评估指向关系图的压缩效率指标：量化唯一事实数量与关系总规模，
 * 分析上下文深度对压缩比率的影响。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出指标：唯一事实计数、关系总规模、上下文深度和压缩效率
from int uniqueFactsCount, int totalRelationsSize, int ctxDepth, float compressionRate
where
  // 唯一事实计数：统计不同(控制流节点, 指向对象, 目标类)组合的数量
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject targetClass |
      exists(PointsToContext analysisContext |
        // 验证在分析上下文中，控制流节点指向对象，且该对象是目标类的实例
        PointsTo::points_to(flowNode, analysisContext, pointedObject, targetClass, _) and
        ctxDepth = analysisContext.getDepth()
      )
    ) and
  // 关系总规模：统计所有(控制流节点, 指向对象, 目标类, 分析上下文, 源节点)组合的数量
  totalRelationsSize =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject targetClass, 
      PointsToContext analysisContext, ControlFlowNode originNode |
      // 验证在分析上下文中，控制流节点指向对象，且该对象是目标类的实例，并记录源节点
      PointsTo::points_to(flowNode, analysisContext, pointedObject, targetClass, originNode) and
      ctxDepth = analysisContext.getDepth()
    ) and
  // 压缩效率计算：唯一事实数量与关系总规模的百分比比率
  compressionRate = 100.0 * uniqueFactsCount / totalRelationsSize
// 输出分析结果：上下文深度、唯一事实计数、关系总规模和压缩效率
select ctxDepth, uniqueFactsCount, totalRelationsSize, compressionRate