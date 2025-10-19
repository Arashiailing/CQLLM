/**
 * 指向关系深度层级分布统计：
 * 本查询用于分析程序中指向关系在不同上下文深度层级的分布情况
 * 
 * 主要统计指标：
 * - 唯一边缘数：在最浅深度层级出现的唯一指向关系数量
 * - 总实例数：特定深度层级上的所有指向关系出现次数总和
 * - 深度效率比：唯一边缘数占总实例数的百分比，表示该深度层级的指向关系效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取给定控制流节点、对象值和类对象的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当节点在某个上下文中指向特定对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 确定给定控制流节点、对象值和类对象的最浅上下文深度
int getMinimumContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 计算所有可能上下文深度的最小值
  result = min(int depth | depth = getContextDepth(node, obj, clsObj))
}

// 分析各深度层级的指向关系分布特征
from int uniqueEdgeCount, int totalInstanceCount, int currentDepth, float depthEfficiencyRatio
where
  // 计算唯一边缘数：统计最浅深度等于当前深度层级的唯一指向关系数量
  uniqueEdgeCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    currentDepth = getMinimumContextDepth(node, obj, clsObj)
  ) and
  // 计算总实例数：统计深度等于当前深度层级的所有指向关系数量
  totalInstanceCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    currentDepth = context.getDepth()
  ) and
  // 计算深度效率比：唯一边缘数占总实例数的百分比
  totalInstanceCount > 0 and  // 防止除以零错误
  depthEfficiencyRatio = 100.0 * uniqueEdgeCount / totalInstanceCount
// 输出深度层级、唯一边缘数、总实例数和深度效率比
select currentDepth, uniqueEdgeCount, totalInstanceCount, depthEfficiencyRatio