/**
 * 分析指向关系数据结构的压缩特性：研究不同上下文深度下，
 * 不同事实组合与完整关系数据集之间的数量比例。
 * 
 * 输出指标解释：
 * - 不同事实计数：唯一的(控制流节点, 目标对象, 对象类型)三元组数量
 * - 关系数据总量：包含上下文信息和源节点的完整指向关系总数
 * - 压缩比率：不同事实数量占关系数据总量的百分比，反映数据压缩程度
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：不同事实计数、关系数据总量、上下文深度和压缩比率
from int distinctFactsCount, int totalRelationSize, int contextDepth, float compressionRatio
where
  // 确定上下文深度并验证存在指向关系
  exists(ControlFlowNode controlNode, Object destObject, ClassObject destClass, PointsToContext contextInfo |
    PointsTo::points_to(controlNode, contextInfo, destObject, destClass, _) and
    contextDepth = contextInfo.getDepth()
  ) and
  // 计算不同事实数量：统计唯一(控制流节点, 目标对象, 对象类型)组合
  distinctFactsCount =
    strictcount(ControlFlowNode controlNode, Object destObject, ClassObject destClass |
      // 筛选特定上下文深度的指向关系
      exists(PointsToContext contextInfo |
        PointsTo::points_to(controlNode, contextInfo, destObject, destClass, _) and
        contextInfo.getDepth() = contextDepth
      )
    ) and
  // 计算关系数据总量：统计包含完整信息的所有指向关系
  totalRelationSize =
    strictcount(ControlFlowNode controlNode, Object destObject, ClassObject destClass, 
      PointsToContext contextInfo, ControlFlowNode originNode |
      // 筛选特定上下文深度的完整指向关系
      PointsTo::points_to(controlNode, contextInfo, destObject, destClass, originNode) and
      contextInfo.getDepth() = contextDepth
    ) and
  // 计算压缩比率：不同事实数量占关系数据总量的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationSize
// 输出结果：上下文深度、不同事实计数、关系数据总量和压缩比率
select contextDepth, distinctFactsCount, totalRelationSize, compressionRatio