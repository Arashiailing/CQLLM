/**
 * 分析上下文深度层级中指向关系的分布特征：
 * - 唯一浅层关系：仅在最小深度层级出现的指向关系总数
 * - 层级总频次：在特定深度层级上所有指向关系的出现次数总和
 * - 深度效率比：唯一浅层关系占总频次的百分比，用于评估该深度层级的指向效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点、目标对象和类对象在指向上下文中的深度值
int getContextDepth(ControlFlowNode controlNode, Object pointedObject, ClassObject targetClass) {
  // 查找节点在指向上下文中关联特定对象和类时的深度层级
  exists(PointsToContext pointsToContext |
    PointsTo::points_to(controlNode, pointsToContext, pointedObject, targetClass, _) and
    result = pointsToContext.getDepth()
  )
}

// 计算控制流节点、对象和类对象的最小上下文深度
int getMinContextDepth(ControlFlowNode controlNode, Object pointedObject, ClassObject targetClass) {
  // 从所有可能的深度值中选取最小值
  result = min(int depth | depth = getContextDepth(controlNode, pointedObject, targetClass))
}

// 按深度层级分析指向关系的分布模式
from int contextDepth, 
     int uniqueShallowRelations, 
     int totalOccurrences, 
     float depthEfficiency
where
  // 统计最小深度等于当前层级的指向关系数量（唯一浅层关系）
  uniqueShallowRelations = strictcount(ControlFlowNode controlNode, Object pointedObject, ClassObject targetClass |
    contextDepth = getMinContextDepth(controlNode, pointedObject, targetClass)
  ) and
  // 统计深度等于当前层级的所有指向关系数量（层级总频次）
  totalOccurrences = strictcount(ControlFlowNode controlNode, Object pointedObject, ClassObject targetClass, 
                              PointsToContext pointsToContext, ControlFlowNode sourceNode |
    PointsTo::points_to(controlNode, pointsToContext, pointedObject, targetClass, sourceNode) and
    contextDepth = pointsToContext.getDepth()
  ) and
  // 防止除以零，确保总频次大于零
  totalOccurrences > 0 and
  // 计算深度效率比：浅层唯一关系占总频次的百分比
  depthEfficiency = 100.0 * uniqueShallowRelations / totalOccurrences
// 输出各深度层级的分析结果
select contextDepth, uniqueShallowRelations, totalOccurrences, depthEfficiency