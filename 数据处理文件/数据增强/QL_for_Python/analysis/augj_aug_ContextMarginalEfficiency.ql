/**
 * 指向关系深度效率分析：
 * 本查询评估不同深度下指向关系的效率指标，包括：
 * - 边际增量：在最浅深度层首次出现的唯一指向关系数量
 * - 总规模：在特定深度层的所有指向关系总数
 * - 效率比：边际增量占总规模的百分比，反映深度层的信息密度
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算指定控制流节点、对象值和类对象的上下文深度
int computeContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在指向上下文使节点在上下文中指向对象且关联类对象时，返回该上下文的深度
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 计算指定控制流节点、对象值和类对象的最浅上下文深度
int computeMinimumDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能上下文深度的最小值
  result = min(int depth | depth = computeContextDepth(node, obj, clsObj))
}

// 分析不同深度下的指向关系指标
from int marginalIncrement, int totalRelations, int analysisDepth, float depthEfficiency
where
  // 计算边际增量：最浅深度等于当前分析深度的唯一指向关系数量
  marginalIncrement = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    analysisDepth = computeMinimumDepth(node, obj, clsObj)
  ) and
  // 计算总规模：深度等于当前分析深度的所有指向关系数量
  totalRelations = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                              PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    analysisDepth = context.getDepth()
  ) and
  // 计算效率比：边际增量占总规模的百分比
  depthEfficiency = 100.0 * marginalIncrement / totalRelations
// 输出分析深度、边际增量、总规模和深度效率
select analysisDepth, marginalIncrement, totalRelations, depthEfficiency