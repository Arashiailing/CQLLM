/**
 * 分析上下文敏感度对指向分析的影响：
 * - 计算每个深度级别新增的指向关系数量（边际事实）
 * - 统计每个深度级别的指向关系总数（总事实）
 * - 计算边际事实占总事实的效率比率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点、目标对象和目标类对象的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject cls) {
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, cls, _) and
    result = context.getDepth()
  )
}

// 确定控制流节点、目标对象和目标类对象的最小上下文深度
int getMinContextDepth(ControlFlowNode node, Object obj, ClassObject cls) {
  result = min(int d | d = getContextDepth(node, obj, cls))
}

// 分析不同上下文深度级别的指向关系统计数据
from int depth, int marginalFacts, int overallFacts, float efficiency
where
  // 计算边际事实：最小深度等于当前深度的三元组数量
  marginalFacts = strictcount(ControlFlowNode node, Object obj, ClassObject cls |
    getMinContextDepth(node, obj, cls) = depth
  ) and
  // 计算总事实：上下文深度等于当前深度的五元组数量
  overallFacts = strictcount(ControlFlowNode node, Object obj, ClassObject cls, 
                           PointsToContext context, ControlFlowNode srcNode |
    PointsTo::points_to(node, context, obj, cls, srcNode) and
    context.getDepth() = depth
  ) and
  // 计算效率比率：边际事实占总事实的百分比
  efficiency = 100.0 * marginalFacts / overallFacts
select depth, marginalFacts, overallFacts, efficiency