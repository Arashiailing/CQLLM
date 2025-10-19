/**
 * 计算边际增加的指向关系事实、指向关系的总大小以及这两者相对于上下文深度的比例。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算给定控制流节点、对象值和类对象的上下文深度
int contextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 计算给定控制流节点、对象值和类对象的最浅上下文深度
int minimalDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  result = min(int d | d = contextDepth(node, obj, clsObj))
}

// 计算总事实数、总大小、上下文深度以及效率（总事实数占总大小的百分比）
from int depth, int totalFacts, int totalSize, float efficiency
where
  // 计算总事实数：满足最浅深度等于当前深度的三元组数量
  totalFacts = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    minimalDepth(node, obj, clsObj) = depth
  ) and
  // 计算总大小：满足上下文深度等于当前深度的五元组数量
  totalSize = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    context.getDepth() = depth
  ) and
  // 计算效率比例
  efficiency = 100.0 * totalFacts / totalSize
select depth, totalFacts, totalSize, efficiency