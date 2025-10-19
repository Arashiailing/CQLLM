/**
 * 指向关系深度分布统计：
 * 此查询用于分析代码库中指向关系的深度分布情况，具体包括：
 * - 唯一关系数：在最浅深度层级上出现的唯一指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系总数
 * - 效率指标：唯一关系数占总关系数的比例，反映该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在特定对象和类对象下的上下文深度
int calculateContextDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 当存在一个指向上下文，使得节点在该上下文中指向目标对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext ctx |
    PointsTo::points_to(node, ctx, targetObj, classObj, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点在特定对象和类对象下的最小上下文深度
int findMinimumContextDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = calculateContextDepth(node, targetObj, classObj))
}

// 分析各深度层级的指向关系特征
from int uniqueRelations, int totalRelations, int currentDepth, float efficiencyMetric
where
  // 计算唯一关系数：最浅深度等于当前深度层级的唯一指向关系数量
  uniqueRelations = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj |
    currentDepth = findMinimumContextDepth(node, targetObj, classObj)
  ) and
  // 计算总关系数：深度等于当前深度层级的所有指向关系数量
  totalRelations = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj, 
                              PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(node, ctx, targetObj, classObj, origin) and
    currentDepth = ctx.getDepth()
  ) and
  // 计算效率指标：唯一关系数占总关系数的百分比
  totalRelations > 0 and  // 避免除以零
  efficiencyMetric = 100.0 * uniqueRelations / totalRelations
// 输出结果：深度层级、唯一关系数、总关系数和效率指标
select currentDepth, uniqueRelations, totalRelations, efficiencyMetric