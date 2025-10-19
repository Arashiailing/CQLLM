/**
 * 探究指向关系在不同深度上下文中的分布特征：
 * - 独特浅层关系：仅在最小深度层级出现的指向关系数量
 * - 整体频率：在特定深度层级上出现的指向关系总数
 * - 上下文效率：独特浅层关系占整体频率的百分比，反映该深度层级的指向关系效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算指定控制流节点、对象和类对象在指向上下文中的深度值
int computeContextualDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在指向上下文使节点在该上下文中指向对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点、对象和类对象的最小上下文深度
int fetchShallowestDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = computeContextualDepth(node, obj, clsObj))
}

// 分析不同深度层级上指向关系的分布情况
from int distinctShallowRelations, int overallFrequency, int depthLevel, float contextualEfficiency
where
  // 计算独特浅层关系：最小深度等于当前深度层级的指向关系数量
  distinctShallowRelations = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = fetchShallowestDepth(node, obj, clsObj)
  ) and
  // 计算整体频率：深度等于当前深度层级的所有指向关系数量
  overallFrequency = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                              PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 计算上下文效率：独特浅层关系占整体频率的百分比
  overallFrequency > 0 and  // 防止除以零的错误
  contextualEfficiency = 100.0 * distinctShallowRelations / overallFrequency
// 输出深度层级、独特浅层关系、整体频率和上下文效率
select depthLevel, distinctShallowRelations, overallFrequency, contextualEfficiency