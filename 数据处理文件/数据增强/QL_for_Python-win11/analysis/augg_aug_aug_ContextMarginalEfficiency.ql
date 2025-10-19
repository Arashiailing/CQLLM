/**
 * 分析 Python 代码中指向关系的深度分布特征：
 * - 边际计数：在最浅深度层级上出现的唯一指向关系数量
 * - 总计数：在特定深度层级上的所有指向关系总数
 * - 效率百分比：边际计数占总计数的比例，用于评估该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取给定控制流节点、对象值和类对象的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在一个指向上下文，使得节点在该上下文中指向对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取给定控制流节点、对象值和类对象的最浅上下文深度
int getMinimumContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(node, obj, clsObj))
}

// 分析各深度层级的指向关系特征
from int uniqueShallowRelations, int totalRelationsAtDepth, int analysisDepth, float depthEfficiency
where
  // 计算边际计数：最浅深度等于当前分析深度的唯一指向关系数量
  uniqueShallowRelations = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    analysisDepth = getMinimumContextDepth(node, obj, clsObj)
  ) and
  // 计算总计数：深度等于当前分析深度的所有指向关系数量
  totalRelationsAtDepth = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    analysisDepth = context.getDepth()
  ) and
  // 计算效率百分比：边际计数占总计数的百分比
  totalRelationsAtDepth > 0 and  // 避免除以零
  depthEfficiency = 100.0 * uniqueShallowRelations / totalRelationsAtDepth
// 输出深度层级、边际计数、总计数和效率百分比
select analysisDepth, uniqueShallowRelations, totalRelationsAtDepth, depthEfficiency