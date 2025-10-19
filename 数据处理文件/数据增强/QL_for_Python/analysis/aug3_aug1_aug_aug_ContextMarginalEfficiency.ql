/**
 * 本查询用于评估指向关系在各个深度层级上的分布情况：
 * - 唯一浅层计数：表示仅在最浅层级出现的指向关系数量
 * - 总频次：表示在特定深度层级上出现的所有指向关系总数
 * - 深度效率：表示唯一浅层计数占总频次的百分比，用于衡量该层级的指向效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算特定控制流节点、对象和类对象在指向上下文中的深度层级
int computeContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在指向上下文使节点在该上下文中指向对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点、对象和类对象的最小上下文深度
int fetchMinimumDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = computeContextDepth(node, obj, clsObj))
}

// 统计各深度层级指向关系的分布特征
from int distinctShallowCount, int overallFrequency, int depthLevel, float depthProductivity
where
  // 计算唯一浅层计数：最浅深度等于当前深度层级的指向关系数量
  distinctShallowCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = fetchMinimumDepth(node, obj, clsObj)
  ) and
  // 计算总频次：深度等于当前深度层级的所有指向关系数量
  overallFrequency = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                              PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 计算深度效率：唯一浅层计数占总频次的百分比
  overallFrequency > 0 and  // 防止除以零的错误
  depthProductivity = 100.0 * distinctShallowCount / overallFrequency
// 输出深度层级、唯一浅层计数、总频次和深度效率
select depthLevel, distinctShallowCount, overallFrequency, depthProductivity