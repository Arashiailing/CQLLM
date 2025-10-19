/**
 * 分析不同上下文深度下的指向关系：
 * - 统计边际增加的指向关系事实（即每个深度下的最小深度事实数）
 * - 计算指向关系的总大小（即每个深度下的所有事实数）
 * - 并计算边际事实相对于总大小的效率比例
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取给定控制流节点、对象值和类对象的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取给定控制流节点、对象值和类对象的最浅上下文深度
int getMinimalDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  result = min(int d | d = getContextDepth(node, obj, clsObj))
}

// 分析不同上下文深度下的指向关系统计
from int contextLevel, int marginalFacts, int overallFacts, float factEfficiency
where
  // 计算边际事实数：满足最浅深度等于当前深度的三元组数量
  marginalFacts = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    getMinimalDepth(node, obj, clsObj) = contextLevel
  ) and
  // 计算总体事实数：满足上下文深度等于当前深度的五元组数量
  overallFacts = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                             PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    context.getDepth() = contextLevel
  ) and
  // 计算效率比例：边际事实数占总事实数的百分比
  factEfficiency = 100.0 * marginalFacts / overallFacts
select contextLevel, marginalFacts, overallFacts, factEfficiency