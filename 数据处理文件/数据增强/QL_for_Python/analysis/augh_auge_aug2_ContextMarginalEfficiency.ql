/**
 * 评估上下文敏感度对指向分析的影响：
 * - 测量每个深度级别新增的指向关系（边际事实）
 * - 统计每个深度级别的指向关系总量（总事实）
 * - 计算边际事实与总事实的效率比率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 提取控制流节点、目标对象和目标类对象的上下文深度
int retrieveContextDepth(ControlFlowNode cfgNode, Object targetObj, ClassObject targetClass) {
  exists(PointsToContext ctx |
    PointsTo::points_to(cfgNode, ctx, targetObj, targetClass, _) and
    result = ctx.getDepth()
  )
}

// 确定控制流节点、目标对象和目标类对象的最小上下文深度
int findMinimalContextDepth(ControlFlowNode cfgNode, Object targetObj, ClassObject targetClass) {
  result = min(int depthVal | depthVal = retrieveContextDepth(cfgNode, targetObj, targetClass))
}

// 分析不同上下文深度级别的指向关系统计数据
from int depthLevel, int incrementalFacts, int totalFacts, float efficiencyRatio
where
  // 计算边际事实：最小深度等于当前深度的三元组数量
  incrementalFacts = strictcount(ControlFlowNode cfgNode, Object targetObj, ClassObject targetClass |
    findMinimalContextDepth(cfgNode, targetObj, targetClass) = depthLevel
  ) and
  // 计算总事实：上下文深度等于当前深度的五元组数量
  totalFacts = strictcount(ControlFlowNode cfgNode, Object targetObj, ClassObject targetClass, 
                           PointsToContext ctx, ControlFlowNode sourceNode |
    PointsTo::points_to(cfgNode, ctx, targetObj, targetClass, sourceNode) and
    ctx.getDepth() = depthLevel
  ) and
  // 计算效率比率：边际事实占总事实的百分比
  efficiencyRatio = 100.0 * incrementalFacts / totalFacts
select depthLevel, incrementalFacts, totalFacts, efficiencyRatio