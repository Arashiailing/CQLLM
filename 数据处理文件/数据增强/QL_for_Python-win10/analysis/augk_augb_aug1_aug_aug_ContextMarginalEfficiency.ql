/**
 * 分析指向关系在不同深度层级上的分布特征与效率指标：
 * - 唯一浅层指针：仅在最小深度层级上出现的指向关系数量
 * - 总体指针频次：在特定深度层级上出现的所有指向关系总和
 * - 指针效率：唯一浅层指针占总体指针频次的百分比，反映该层级指向关系的有效性
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 确定控制流节点、目标对象和类对象在指向上下文中的深度层级
int calculateContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在指向上下文使节点在该上下文中指向目标对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点、对象和类对象的最小上下文深度值
int getMinimumContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = calculateContextDepth(node, obj, clsObj))
}

// 分析各深度层级指向关系的分布特征与效率指标
from int uniqueShallowPointers, int totalPointersAtDepth, int currentDepth, float pointerEfficiency
where
  // 计算唯一浅层指针：最小深度等于当前深度层级的指向关系数量
  uniqueShallowPointers = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    currentDepth = getMinimumContextDepth(node, obj, clsObj)
  ) and
  // 计算总体指针频次：深度等于当前深度层级的所有指向关系数量
  totalPointersAtDepth = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                                   PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    currentDepth = context.getDepth()
  ) and
  // 确保总体指针频次大于零，避免除以零错误
  totalPointersAtDepth > 0 and
  // 计算指针效率：唯一浅层指针占总体指针频次的百分比
  pointerEfficiency = 100.0 * uniqueShallowPointers / totalPointersAtDepth
// 输出深度层级、唯一浅层指针、总体指针频次和指针效率
select currentDepth, uniqueShallowPointers, totalPointersAtDepth, pointerEfficiency