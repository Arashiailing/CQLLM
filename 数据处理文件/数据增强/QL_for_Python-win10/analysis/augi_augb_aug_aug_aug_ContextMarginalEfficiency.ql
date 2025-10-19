/**
 * 指向关系深度分布分析：
 * 本查询用于统计代码库中指向关系的深度分布情况，主要包含：
 * - 唯一关系数：在最浅深度层级上出现的唯一指向关系数量
 * - 总关系数：在特定深度层级上的所有指向关系总数
 * - 效率指标：唯一关系数占总关系数的比例，表示该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点在特定对象和类对象下的最小上下文深度
int getMinimumContextDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 当存在指向上下文使节点指向目标对象并关联类对象时，返回最小深度值
  result = min(int depth |
    exists(PointsToContext ctx |
      PointsTo::points_to(node, ctx, targetObj, classObj, _) and
      depth = ctx.getDepth()
    )
  )
}

// 分析各深度层级的指向关系特征
from int distinctRelations, int overallRelations, int depthLevel, float efficiencyRatio
where
  // 计算唯一关系数：最浅深度等于当前深度层级的唯一指向关系数量
  distinctRelations = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj |
    depthLevel = getMinimumContextDepth(node, targetObj, classObj)
  ) and
  // 计算总关系数：深度等于当前深度层级的所有指向关系数量
  overallRelations = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj, 
                                PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(node, ctx, targetObj, classObj, origin) and
    depthLevel = ctx.getDepth()
  ) and
  // 计算效率指标：唯一关系数占总关系数的百分比
  overallRelations > 0 and  // 避免除以零
  efficiencyRatio = 100.0 * distinctRelations / overallRelations
// 输出结果：深度层级、唯一关系数、总关系数和效率指标
select depthLevel, distinctRelations, overallRelations, efficiencyRatio