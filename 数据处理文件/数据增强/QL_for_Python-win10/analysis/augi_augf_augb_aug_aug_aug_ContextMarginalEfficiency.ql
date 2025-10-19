/**
 * 指向关系深度分布统计：
 * 此查询分析代码库中指向关系的深度分布情况，统计指标包括：
 * - 唯一关系数：在最小深度层级上出现的不同指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系实例总数
 * - 效率指标：唯一关系数占总关系数的比例，评估该深度层级的指向效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点在指向特定对象和类对象时的上下文深度值
int retrieveContextDepth(ControlFlowNode flowNode, Object targetEntity, ClassObject classEntity) {
  // 当节点在某个上下文中指向目标对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(flowNode, context, targetEntity, classEntity, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点指向特定对象和类对象时的最小上下文深度值
int findMinimumContextDepth(ControlFlowNode flowNode, Object targetEntity, ClassObject classEntity) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = retrieveContextDepth(flowNode, targetEntity, classEntity))
}

// 分析不同深度层级的指向关系特征
from int distinctRelations, int aggregateRelations, int currentDepth, float efficiencyMetric
where
  // 计算唯一关系数：最小深度等于当前深度层级的唯一指向关系数量
  distinctRelations = strictcount(ControlFlowNode flowNode, Object targetEntity, ClassObject classEntity |
    currentDepth = findMinimumContextDepth(flowNode, targetEntity, classEntity)
  ) and
  // 计算总关系数：深度等于当前深度层级的所有指向关系实例数量
  aggregateRelations = strictcount(ControlFlowNode flowNode, Object targetEntity, ClassObject classEntity, 
                         PointsToContext context, ControlFlowNode sourceNode |
    PointsTo::points_to(flowNode, context, targetEntity, classEntity, sourceNode) and
    currentDepth = context.getDepth()
  ) and
  // 计算效率指标：唯一关系数占总关系数的百分比
  aggregateRelations > 0 and  // 避免除以零
  efficiencyMetric = 100.0 * distinctRelations / aggregateRelations
// 输出结果：深度层级、唯一关系数、总关系数和效率指标
select currentDepth, distinctRelations, aggregateRelations, efficiencyMetric