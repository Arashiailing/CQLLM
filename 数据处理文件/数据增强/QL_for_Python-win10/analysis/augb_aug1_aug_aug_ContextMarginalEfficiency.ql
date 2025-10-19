/**
 * 探究指向关系在各个深度层级上的分布情况与特征：
 * - 唯一浅层关系：仅在最小深度层级上存在的指向关系数量
 * - 整体频次：在特定深度层级上出现的所有指向关系总和
 * - 效率比率：唯一浅层关系占整体频次的百分比，表示该层级的指向关系效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算给定控制流节点、目标对象和类对象在指向上下文中的深度层级
int computeContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在指向上下文使节点在该上下文中指向对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点、对象和类对象的最小上下文深度
int findMinimumDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = computeContextDepth(node, obj, clsObj))
}

// 分析各深度层级指向关系的分布特征
from int distinctShallowRelations, int overallFrequency, int depthLevel, float efficiencyRatio
where
  // 计算唯一浅层关系：最小深度等于当前深度层级的指向关系数量
  distinctShallowRelations = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = findMinimumDepth(node, obj, clsObj)
  ) and
  // 计算整体频次：深度等于当前深度层级的所有指向关系数量
  overallFrequency = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                              PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 计算效率比率：唯一浅层关系占整体频次的百分比
  overallFrequency > 0 and  // 防止除以零的错误
  efficiencyRatio = 100.0 * distinctShallowRelations / overallFrequency
// 输出深度层级、唯一浅层关系、整体频次和效率比率
select depthLevel, distinctShallowRelations, overallFrequency, efficiencyRatio