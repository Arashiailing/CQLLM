/**
 * 指向关系深度分布统计：
 * 此查询分析代码库中指向关系的深度分布特征，包括：
 * - 唯一关系数：在最小深度层级上出现的不同指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系实例总数
 * - 效率度量：唯一关系数占总关系数的比例，反映该深度层级的有效性
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点指向特定对象和类对象时的最小上下文深度
int calculateMinContextDepth(ControlFlowNode cfNode, Object targetObject, ClassObject classObject) {
  // 当存在指向上下文使节点指向目标对象并关联类对象时，返回最小深度值
  result = min(int depth |
    exists(PointsToContext context |
      PointsTo::points_to(cfNode, context, targetObject, classObject, _) and
      depth = context.getDepth()
    )
  )
}

// 分析不同深度层级的指向关系分布特征
from int uniqueRelations, int totalRelations, int contextDepth, float efficiencyMetric
where
  // 统计唯一关系数：最小上下文深度等于当前层级的指向关系数量
  uniqueRelations = strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject classObject |
    contextDepth = calculateMinContextDepth(cfNode, targetObject, classObject)
  ) and
  // 统计总关系数：上下文深度等于当前层级的所有指向关系实例数量
  totalRelations = strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject classObject, 
                               PointsToContext context, ControlFlowNode originNode |
    PointsTo::points_to(cfNode, context, targetObject, classObject, originNode) and
    contextDepth = context.getDepth()
  ) and
  // 计算效率度量：唯一关系数占总关系数的百分比
  totalRelations > 0 and  // 防止除以零错误
  efficiencyMetric = 100.0 * uniqueRelations / totalRelations
// 输出分析结果：上下文深度、唯一关系数、总关系数及效率度量
select contextDepth, uniqueRelations, totalRelations, efficiencyMetric