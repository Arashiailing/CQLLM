/**
 * 指向关系深度分布分析：
 * 统计代码库中不同深度层级的指向关系特征，包括：
 * - 唯一关系数：在最浅深度出现的唯一指向关系数量
 * - 总关系数：特定深度层级的所有指向关系总数
 * - 效率指标：唯一关系数占总关系数的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点在特定对象和类对象下的上下文深度
int getCtxDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 当节点在某个上下文中指向目标对象并关联类对象时，返回该上下文深度
  exists(PointsToContext ctx |
    PointsTo::points_to(node, ctx, targetObj, classObj, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点在特定对象和类对象下的最小上下文深度
int getMinCtxDepth(ControlFlowNode node, Object targetObj, ClassObject classObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getCtxDepth(node, targetObj, classObj))
}

// 分析各深度层级的指向关系特征
from int uniqueRels, int totalRels, int depthLevel, float efficiency
where
  // 计算唯一关系数：最浅深度等于当前深度的唯一指向关系数量
  uniqueRels = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj |
    depthLevel = getMinCtxDepth(node, targetObj, classObj)
  ) and
  // 计算总关系数：深度等于当前深度的所有指向关系数量
  totalRels = strictcount(ControlFlowNode node, Object targetObj, ClassObject classObj, 
                         PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(node, ctx, targetObj, classObj, origin) and
    depthLevel = ctx.getDepth()
  ) and
  // 计算效率指标：唯一关系数占总关系数的百分比（避免除零）
  totalRels > 0 and
  efficiency = 100.0 * uniqueRels / totalRels
// 输出结果：深度层级、唯一关系数、总关系数和效率指标
select depthLevel, uniqueRels, totalRels, efficiency