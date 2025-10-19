/**
 * 指向关系深度分布分析：
 * 本查询用于评估代码库中指向关系的深度分布特征，包括：
 * - 唯一关系数：在最浅深度层级上出现的唯一指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系总数
 * - 效率比率：唯一关系数占总关系数的百分比，用于衡量该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点指向特定对象和类对象时的上下文深度
int getContextDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 当节点在某个上下文中指向目标对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext ctx |
    PointsTo::points_to(node, ctx, targetObj, classObj, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点指向特定对象和类对象时的最小上下文深度
int getMinContextDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(node, targetObj, classObj))
}

// 分析不同深度层级的指向关系特征
from int uniqueRels, int totalRels, int depthLevel, float efficiencyRatio
where
  // 计算唯一关系数：最浅深度等于当前深度层级的唯一指向关系数量
  uniqueRels = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj |
    depthLevel = getMinContextDepth(node, targetObj, classObj)
  ) and
  // 计算总关系数：深度等于当前深度层级的所有指向关系数量
  totalRels = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj, 
                         PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(node, ctx, targetObj, classObj, origin) and
    depthLevel = ctx.getDepth()
  ) and
  // 计算效率比率：唯一关系数占总关系数的百分比
  totalRels > 0 and  // 避免除以零
  efficiencyRatio = 100.0 * uniqueRels / totalRels
// 输出结果：深度层级、唯一关系数、总关系数和效率比率
select depthLevel, uniqueRels, totalRels, efficiencyRatio