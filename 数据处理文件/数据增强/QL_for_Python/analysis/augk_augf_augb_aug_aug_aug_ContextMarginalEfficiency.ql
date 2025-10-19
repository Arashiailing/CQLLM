/**
 * 指向关系深度分布特征分析：
 * 此查询用于评估代码库中指向关系的深度分布情况，主要关注：
 * - 唯一关系数：在最浅深度层级上出现的不同指向关系数量
 * - 总关系数：在特定深度层级上所有指向关系的总数
 * - 效率指标：唯一关系数占总关系数的百分比，表示该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点指向特定对象和类对象时的上下文深度
int determineContextDepth(ControlFlowNode cfNode, Object pointedObject, ClassObject relatedClass) {
  // 当节点在特定上下文中指向目标对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(cfNode, context, pointedObject, relatedClass, _) and
    result = context.getDepth()
  )
}

// 确定控制流节点指向特定对象和类对象时的最小上下文深度
int findMinimumContextDepth(ControlFlowNode cfNode, Object pointedObject, ClassObject relatedClass) {
  // 计算并返回所有可能深度的最小值
  result = min(int contextDepth | contextDepth = determineContextDepth(cfNode, pointedObject, relatedClass))
}

// 分析各个深度层级的指向关系分布情况
from int distinctRelations, int allRelations, int depthTier, float efficiencyMetric
where
  // 计算唯一关系数：最浅深度等于当前深度层级的不同指向关系数量
  distinctRelations = strictcount(ControlFlowNode cfNode, Object pointedObject, ClassObject relatedClass |
    depthTier = findMinimumContextDepth(cfNode, pointedObject, relatedClass)
  ) and
  // 计算总关系数：深度等于当前深度层级的所有指向关系总数
  allRelations = strictcount(ControlFlowNode cfNode, Object pointedObject, ClassObject relatedClass, 
                         PointsToContext context, ControlFlowNode sourceNode |
    PointsTo::points_to(cfNode, context, pointedObject, relatedClass, sourceNode) and
    depthTier = context.getDepth()
  ) and
  // 计算效率指标：唯一关系数占总关系数的百分比
  allRelations > 0 and  // 防止除以零错误
  efficiencyMetric = 100.0 * distinctRelations / allRelations
// 输出结果：深度层级、唯一关系数、总关系数和效率指标
select depthTier, distinctRelations, allRelations, efficiencyMetric