/**
 * 指向关系深度分布统计：
 * 此查询用于评估代码库中指向关系的深度分布情况，统计指标包括：
 * - 唯一关系数：在指定深度层级上首次出现的唯一指向关系数量
 * - 关系总数：在特定深度层级上存在的所有指向关系总数
 * - 效率比率：唯一关系数占关系总数的百分比，反映该深度层级的有效性
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在给定目标对象和类对象下的上下文深度
int calculateContextDepth(ControlFlowNode flowNode, Object targetObject, ClassObject classTarget) {
  // 当存在指向上下文使得节点在该上下文中指向目标对象并关联类目标时，返回该上下文的深度值
  exists(PointsToContext pointContext |
    PointsTo::points_to(flowNode, pointContext, targetObject, classTarget, _) and
    result = pointContext.getDepth()
  )
}

// 确定控制流节点在给定目标对象和类对象下的最小上下文深度
int findMinimumContextDepth(ControlFlowNode flowNode, Object targetObject, ClassObject classTarget) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = calculateContextDepth(flowNode, targetObject, classTarget))
}

// 统计各深度层级的指向关系分布特征
from int uniqueRelationsCount, int totalRelationsCount, int currentDepth, float efficiencyRatio
where
  // 统计唯一关系数：最小深度等于当前深度的唯一指向关系数量
  uniqueRelationsCount = strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject classTarget |
    currentDepth = findMinimumContextDepth(flowNode, targetObject, classTarget)
  ) and
  // 统计关系总数：深度等于当前深度的所有指向关系数量
  totalRelationsCount = strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject classTarget, 
                                   PointsToContext pointContext, ControlFlowNode sourceNode |
    PointsTo::points_to(flowNode, pointContext, targetObject, classTarget, sourceNode) and
    currentDepth = pointContext.getDepth()
  ) and
  // 计算效率比率：唯一关系数占关系总数的百分比
  totalRelationsCount > 0 and  // 防止除零错误
  efficiencyRatio = 100.0 * uniqueRelationsCount / totalRelationsCount
// 输出结果：当前深度、唯一关系数、关系总数和效率比率
select currentDepth, uniqueRelationsCount, totalRelationsCount, efficiencyRatio