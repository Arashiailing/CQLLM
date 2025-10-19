/**
 * 指向关系深度分布统计：
 * 本查询分析代码库中指向关系的深度分布情况，关注以下指标：
 * - 唯一关系数：在特定深度层级上作为最小深度的唯一指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系实例总数
 * - 效率指标：唯一关系数占总关系数的比例，衡量该深度层级的有效性
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在指定目标和类实例下的上下文深度
int calculateContextDepth(ControlFlowNode node, Object target, ClassObject clsInstance) {
  // 当节点在某个上下文中指向目标对象并关联类实例时，返回该上下文的深度
  exists(PointsToContext context |
    PointsTo::points_to(node, context, target, clsInstance, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点在指定目标和类实例下的最小上下文深度
int getMinimalContextDepth(ControlFlowNode node, Object target, ClassObject clsInstance) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = calculateContextDepth(node, target, clsInstance))
}

// 统计不同深度层级的指向关系特征
from int uniqueRelations, int allRelations, int depthLevel, float efficiencyMetric
where
  // 统计唯一关系数：最小深度等于当前层级的指向关系数量
  uniqueRelations = strictcount(ControlFlowNode node, Object target, ClassObject clsInstance |
    depthLevel = getMinimalContextDepth(node, target, clsInstance)
  ) and
  // 统计总关系数：深度等于当前层级的所有指向关系实例数
  allRelations = strictcount(ControlFlowNode node, Object target, ClassObject clsInstance, 
                            PointsToContext context, ControlFlowNode sourceNode |
    PointsTo::points_to(node, context, target, clsInstance, sourceNode) and
    depthLevel = context.getDepth()
  ) and
  // 计算效率指标：唯一关系数占总关系数的百分比
  allRelations > 0 and  // 防止除零错误
  efficiencyMetric = 100.0 * uniqueRelations / allRelations
// 输出结果：深度层级、唯一关系数、总关系数和效率指标
select depthLevel, uniqueRelations, allRelations, efficiencyMetric