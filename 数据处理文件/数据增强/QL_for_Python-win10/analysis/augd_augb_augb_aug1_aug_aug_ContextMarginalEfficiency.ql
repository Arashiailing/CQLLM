/**
 * 探究指向关系在上下文深度层级中的分布模式：
 * - 浅层唯一计数：仅在最浅深度层级出现的指向关系数量
 * - 总体频率：特定深度层级上所有指向关系的出现次数
 * - 效率指标：浅层唯一计数占总体频率的百分比，反映该层级指向关系的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 确定控制流节点、目标对象和类对象在指向上下文中的深度层级
int determineContextDepth(ControlFlowNode cfNode, Object targetObject, ClassObject classObject) {
  // 当节点在某个指向上下文中指向特定对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext ptContext |
    PointsTo::points_to(cfNode, ptContext, targetObject, classObject, _) and
    result = ptContext.getDepth()
  )
}

// 获取控制流节点、对象和类对象的最小上下文深度
int findMinimumDepth(ControlFlowNode cfNode, Object targetObject, ClassObject classObject) {
  // 返回所有可能深度值中的最小深度
  result = min(int depth | depth = determineContextDepth(cfNode, targetObject, classObject))
}

// 分析不同深度层级指向关系的分布特征
from int depthLevel, 
     int shallowUniqueCount, 
     int overallFrequency, 
     float efficiencyRatio
where
  // 计算浅层唯一计数：最小深度等于当前深度层级的指向关系数量
  shallowUniqueCount = strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject classObject |
    depthLevel = findMinimumDepth(cfNode, targetObject, classObject)
  ) and
  // 计算总体频率：深度等于当前深度层级的所有指向关系数量
  overallFrequency = strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject classObject, 
                              PointsToContext ptContext, ControlFlowNode originNode |
    PointsTo::points_to(cfNode, ptContext, targetObject, classObject, originNode) and
    depthLevel = ptContext.getDepth()
  ) and
  // 确保总体频率大于零，避免除以零的错误
  overallFrequency > 0 and
  // 计算效率指标：浅层唯一计数占总体频率的百分比
  efficiencyRatio = 100.0 * shallowUniqueCount / overallFrequency
// 输出深度层级、浅层唯一计数、总体频率和效率指标
select depthLevel, shallowUniqueCount, overallFrequency, efficiencyRatio