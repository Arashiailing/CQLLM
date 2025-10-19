/**
 * 指向关系上下文深度分布分析：
 * - 唯一浅层指向：仅在最小深度层级出现的指向关系数量
 * - 总体出现频次：在特定深度层级中所有指向关系的总和
 * - 深度效率指标：唯一浅层指向与总体出现频次的比率（百分比形式）
 *   该指标反映了在特定深度层级上指向关系的"效率"或"独特性"
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 检索控制流节点、目标对象和类对象在指向上下文中的深度层级
int retrieveContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当节点在某个指向上下文中指向特定对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 查找控制流节点、对象和类对象的最小上下文深度
int findMinimumContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = retrieveContextDepth(node, obj, clsObj))
}

// 分析各深度层级指向关系的分布特征
from int depthLevel, 
     int distinctShallowPointers, 
     int overallFrequency, 
     float depthEfficiencyRatio
where
  // 计算唯一浅层指向：最小深度等于当前深度层级的指向关系数量
  distinctShallowPointers = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = findMinimumContextDepth(node, obj, clsObj)
  ) and
  // 计算总体出现频次：深度等于当前深度层级的所有指向关系数量
  overallFrequency = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                              PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 确保总体出现频次大于零，避免除以零的错误
  overallFrequency > 0 and
  // 计算深度效率指标：唯一浅层指向占总体出现频次的百分比
  depthEfficiencyRatio = 100.0 * distinctShallowPointers / overallFrequency
// 输出深度层级、唯一浅层指向、总体出现频次和深度效率指标
select depthLevel, distinctShallowPointers, overallFrequency, depthEfficiencyRatio