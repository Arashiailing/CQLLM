/**
 * 指向关系深度分布特征分析：
 * 此查询用于评估代码库中指向关系的深度分布模式，重点分析：
 * - 边际关系数：在最浅深度层级上出现的唯一指向关系数量
 * - 关系总数：在特定深度层级上的所有指向关系实例数
 * - 效率比率：边际关系数占总关系数的百分比，反映该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 确定控制流节点在给定目标对象和类实例下的上下文深度
int determineContextDepth(ControlFlowNode cfNode, Object targetObj, ClassObject classInstance) {
  // 当存在指向上下文使节点在该上下文中指向目标对象并关联类实例时，返回上下文深度
  exists(PointsToContext ptContext |
    PointsTo::points_to(cfNode, ptContext, targetObj, classInstance, _) and
    result = ptContext.getDepth()
  )
}

// 获取控制流节点在给定目标对象和类实例下的最小上下文深度
int fetchMinimumContextDepth(ControlFlowNode cfNode, Object targetObj, ClassObject classInstance) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = determineContextDepth(cfNode, targetObj, classInstance))
}

// 分析不同深度层级的指向关系特征
from int edgeCount, int totalRelations, int depthTier, float efficiencyRatio
where
  // 计算边际关系数：最浅深度等于当前深度层级的唯一指向关系数量
  edgeCount = strictcount(ControlFlowNode cfNode, Object targetObj, ClassObject classInstance |
    depthTier = fetchMinimumContextDepth(cfNode, targetObj, classInstance)
  ) and
  // 计算关系总数：深度等于当前深度层级的所有指向关系数量
  totalRelations = strictcount(ControlFlowNode cfNode, Object targetObj, ClassObject classInstance, 
                              PointsToContext ptContext, ControlFlowNode originNode |
    PointsTo::points_to(cfNode, ptContext, targetObj, classInstance, originNode) and
    depthTier = ptContext.getDepth()
  ) and
  // 计算效率比率：边际关系数占总关系数的百分比
  totalRelations > 0 and  // 避免除以零错误
  efficiencyRatio = 100.0 * edgeCount / totalRelations
// 输出结果：深度层级、边际关系数、关系总数和效率比率
select depthTier, edgeCount, totalRelations, efficiencyRatio