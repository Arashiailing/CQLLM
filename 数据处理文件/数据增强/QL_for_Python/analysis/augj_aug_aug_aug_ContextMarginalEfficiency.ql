/**
 * 指向关系深度分布分析：
 * 本查询分析代码库中指向关系的深度分布特征，量化各深度层级的效率指标：
 * - 边际计数：在最小深度层级出现的唯一指向关系数量
 * - 总计数：特定深度层级上的所有指向关系总数
 * - 效率百分比：边际计数占总计数的比例，反映该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点在特定对象和类对象下的上下文深度
int getContextDepth(ControlFlowNode cfNode, Object pointedToObj, ClassObject classObj) {
  // 当存在指向上下文使节点在该上下文中指向对象并关联类对象时，返回上下文深度
  exists(PointsToContext ctx |
    PointsTo::points_to(cfNode, ctx, pointedToObj, classObj, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点在特定对象和类对象下的最小上下文深度
int getMinContextDepth(ControlFlowNode cfNode, Object pointedToObj, ClassObject classObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(cfNode, pointedToObj, classObj))
}

// 分析各深度层级的指向关系特征
from int marginalCount, int totalCount, int depthLevel, float efficiencyPercentage
where
  // 计算边际计数：最小深度等于当前层级的唯一指向关系数量
  marginalCount = strictcount(ControlFlowNode cfNode, Object pointedToObj, ClassObject classObj |
    depthLevel = getMinContextDepth(cfNode, pointedToObj, classObj)
  ) and
  // 计算总计数：深度等于当前层级的所有指向关系数量
  totalCount = strictcount(
    ControlFlowNode cfNode,
    Object pointedToObj,
    ClassObject classObj,
    PointsToContext ctx,
    ControlFlowNode originNode
  |
    PointsTo::points_to(cfNode, ctx, pointedToObj, classObj, originNode) and
    depthLevel = ctx.getDepth()
  ) and
  // 计算效率百分比：边际计数占总计数的百分比（避免除以零）
  totalCount > 0 and
  efficiencyPercentage = 100.0 * marginalCount / totalCount
// 输出结果：深度层级、边际计数、总计数和效率百分比
select depthLevel, marginalCount, totalCount, efficiencyPercentage