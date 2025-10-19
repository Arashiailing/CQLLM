/**
 * 分析指向关系数据结构的压缩特性：评估不同上下文深度下
 * 数据结构的唯一性比例，衡量压缩算法的有效性。
 * 
 * 性能指标包括：
 * - 不同事实数量：不重复的(控制流节点, 目标对象, 对象类)组合数
 * - 总关系数量：包含完整上下文和源节点信息的关系总数
 * - 压缩比率：唯一事实占总关系的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：不同事实计数、总关系数、上下文深度和压缩比率
from int distinctFactsCount, int overallRelationCount, int contextDepth, float compressionRatio
where
  // 确定存在指向关系并获取上下文深度
  exists(ControlFlowNode flowNode, Object destObject, ClassObject objectClass, PointsToContext pointContext |
    PointsTo::points_to(flowNode, pointContext, destObject, objectClass, _) and
    contextDepth = pointContext.getDepth()
  ) and
  // 计算不同事实数量：统计唯一(控制流节点, 目标对象, 对象类)三元组
  distinctFactsCount =
    strictcount(ControlFlowNode flowNode, Object destObject, ClassObject objectClass |
      // 筛选特定上下文深度的指向关系
      exists(PointsToContext pointContext |
        PointsTo::points_to(flowNode, pointContext, destObject, objectClass, _) and
        pointContext.getDepth() = contextDepth
      )
    ) and
  // 计算总关系数量：统计完整五元组(控制流节点, 目标对象, 对象类, 上下文, 源节点)
  overallRelationCount =
    strictcount(ControlFlowNode flowNode, Object destObject, ClassObject objectClass, 
      PointsToContext pointContext, ControlFlowNode originNode |
      // 筛选特定上下文深度的完整指向关系
      PointsTo::points_to(flowNode, pointContext, destObject, objectClass, originNode) and
      pointContext.getDepth() = contextDepth
    ) and
  // 计算压缩比率：唯一事实占总关系的百分比
  compressionRatio = 100.0 * distinctFactsCount / overallRelationCount
// 输出结果：上下文深度、不同事实数量、总关系数量和压缩比率
select contextDepth, distinctFactsCount, overallRelationCount, compressionRatio