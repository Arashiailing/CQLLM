/**
 * 指向关系深度分布分析：
 * 本查询分析代码库中指向关系的深度分布，提供以下统计指标：
 * - 唯一关系数：在特定深度首次出现的唯一指向关系数量
 * - 关系总数：在指定深度层级的所有指向关系总数
 * - 效率比率：唯一关系数与关系总数的百分比，表示该深度层级的有效性
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在指定目标对象和类对象下的上下文深度值
int getContextDepth(ControlFlowNode node, Object targetObj, ClassObject targetClass) {
  // 当节点在某个上下文中指向目标对象并关联目标类时，返回该上下文的深度
  exists(PointsToContext ctx |
    PointsTo::points_to(node, ctx, targetObj, targetClass, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点在给定目标对象和类对象下的最小上下文深度
int getMinContextDepth(ControlFlowNode node, Object targetObj, ClassObject targetClass) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = getContextDepth(node, targetObj, targetClass))
}

// 分析各深度层级的指向关系分布特征
from int uniqueCount, int totalCount, int depthLevel, float efficiency
where
  // 计算唯一关系数：最小深度等于当前层级的唯一指向关系数量
  uniqueCount = strictcount(ControlFlowNode node, Object targetObj, ClassObject targetClass |
    depthLevel = getMinContextDepth(node, targetObj, targetClass)
  ) and
  // 计算关系总数：深度等于当前层级的所有指向关系数量
  totalCount = strictcount(ControlFlowNode node, Object targetObj, ClassObject targetClass, 
                          PointsToContext ctx, ControlFlowNode source |
    PointsTo::points_to(node, ctx, targetObj, targetClass, source) and
    depthLevel = ctx.getDepth()
  ) and
  // 计算效率比率：唯一关系数占关系总数的百分比
  totalCount > 0 and  // 避免除零错误
  efficiency = 100.0 * uniqueCount / totalCount
// 输出结果：深度层级、唯一关系数、关系总数和效率比率
select depthLevel, uniqueCount, totalCount, efficiency