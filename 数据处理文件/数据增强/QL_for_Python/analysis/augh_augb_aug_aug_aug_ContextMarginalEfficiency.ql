/**
 * 指向关系深度分布分析：
 * 本查询统计代码库中指向关系在不同深度层级的分布特征，包括：
 * - 唯一关系数：在最浅深度层级上出现的唯一指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系总数
 * - 效率比率：唯一关系数占总关系数的比例，用于评估该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点指向特定对象和类时的上下文深度
int getContextDepth(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass) {
  // 当节点在某个上下文中指向目标对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext context |
    PointsTo::points_to(cfNode, context, pointedObject, pointedClass, _) and
    result = context.getDepth()
  )
}

// 确定控制流节点指向特定对象和类时的最小上下文深度
int getMinContextDepth(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(cfNode, pointedObject, pointedClass))
}

// 分析各深度层级的指向关系分布特征
from int uniqueCount, int totalCount, int depthLevel, float efficiencyRatio
where
  // 统计在最浅深度等于当前层级的唯一指向关系数量
  uniqueCount = strictcount(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass |
    depthLevel = getMinContextDepth(cfNode, pointedObject, pointedClass)
  ) and
  // 统计在深度等于当前层级的所有指向关系数量
  totalCount = strictcount(ControlFlowNode cfNode, Object pointedObject, ClassObject pointedClass, 
                          PointsToContext context, ControlFlowNode sourceNode |
    PointsTo::points_to(cfNode, context, pointedObject, pointedClass, sourceNode) and
    depthLevel = context.getDepth()
  ) and
  // 计算效率比率：唯一关系数占总关系数的百分比
  totalCount > 0 and  // 防止除以零错误
  efficiencyRatio = 100.0 * uniqueCount / totalCount
// 输出结果：深度层级、唯一关系数、总关系数和效率比率
select depthLevel, uniqueCount, totalCount, efficiencyRatio