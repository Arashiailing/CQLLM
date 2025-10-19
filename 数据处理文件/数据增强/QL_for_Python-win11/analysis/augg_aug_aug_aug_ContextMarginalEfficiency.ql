/**
 * 指向关系深度分布分析：
 * 本查询分析代码库中指向关系的深度分布特征，评估不同深度层级的效率。
 * 关键指标包括：
 * - 唯一浅层关系数：在最浅深度层级出现的唯一指向关系数量
 * - 深度层总关系数：在特定深度层级上的所有指向关系总数
 * - 深度效率百分比：唯一浅层关系数占深度层总关系数的比例，反映该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在特定对象和类对象下的上下文深度
int getPointingContextDepth(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass) {
  // 当存在一个指向上下文，使得节点在该上下文中指向对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext ptContext |
    PointsTo::points_to(cfNode, ptContext, pointedObject, pointedClass, _) and
    result = ptContext.getDepth()
  )
}

// 获取控制流节点在特定对象和类对象下的最小上下文深度
int getMinimumContextDepth(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getPointingContextDepth(cfNode, pointedObject, pointedClass))
}

// 分析各深度层级的指向关系特征
from int uniqueShallowRelations, int totalRelationsAtDepth, int currentDepth, float depthEfficiency
where
  // 计算唯一浅层关系数：最浅深度等于当前深度层级的唯一指向关系数量
  uniqueShallowRelations = strictcount(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass |
    currentDepth = getMinimumContextDepth(cfNode, pointedObject, pointedClass)
  ) and
  // 计算深度层总关系数：深度等于当前深度层级的所有指向关系数量
  totalRelationsAtDepth = strictcount(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass, 
                          PointsToContext ptContext, ControlFlowNode originNode |
    PointsTo::points_to(cfNode, ptContext, pointedObject, pointedClass, originNode) and
    currentDepth = ptContext.getDepth()
  ) and
  // 计算深度效率百分比：唯一浅层关系数占深度层总关系数的百分比
  totalRelationsAtDepth > 0 and  // 避免除以零
  depthEfficiency = 100.0 * uniqueShallowRelations / totalRelationsAtDepth
// 输出结果：深度层级、唯一浅层关系数、深度层总关系数和深度效率百分比
select currentDepth, uniqueShallowRelations, totalRelationsAtDepth, depthEfficiency