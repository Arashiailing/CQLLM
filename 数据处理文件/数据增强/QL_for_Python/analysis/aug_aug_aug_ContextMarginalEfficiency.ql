/**
 * 指向关系深度分布分析：
 * 本查询用于分析代码中指向关系的深度分布特征，包括：
 * - 边际计数：在最浅深度层级上出现的唯一指向关系数量
 * - 总计数：在特定深度层级上的所有指向关系总数
 * - 效率百分比：边际计数占总计数的比例，表示该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在特定对象和类对象下的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在一个指向上下文，使得节点在该上下文中指向对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点在特定对象和类对象下的最小上下文深度
int getMinContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(node, obj, clsObj))
}

// 分析各深度层级的指向关系特征
from int marginalCount, int totalCount, int depthLevel, float efficiencyPercentage
where
  // 计算边际计数：最浅深度等于当前深度层级的唯一指向关系数量
  marginalCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = getMinContextDepth(node, obj, clsObj)
  ) and
  // 计算总计数：深度等于当前深度层级的所有指向关系数量
  totalCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 计算效率百分比：边际计数占总计数的百分比
  totalCount > 0 and  // 避免除以零
  efficiencyPercentage = 100.0 * marginalCount / totalCount
// 输出结果：深度层级、边际计数、总计数和效率百分比
select depthLevel, marginalCount, totalCount, efficiencyPercentage