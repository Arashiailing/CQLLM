/**
 * 分析指向关系数据在不同上下文深度的分布特征：
 * - 统计每个深度下的边际指向关系事实数量
 * - 计算指向关系总规模
 * - 测量边际事实占总规模的比例（效率指标）
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算指定控制流节点、对象值和类对象在指向关系中的上下文深度
int computeContextDepth(ControlFlowNode node, Object target, ClassObject type) {
  // 存在指向上下文ctx，使得node在ctx中指向target且类型为type，返回ctx的深度值
  exists(PointsToContext ctx |
    PointsTo::points_to(node, ctx, target, type, _) and
    result = ctx.getDepth()
  )
}

// 获取指定控制流节点、对象值和类对象的最浅上下文深度
int computeMinimumDepth(ControlFlowNode node, Object target, ClassObject type) {
  // 返回所有可能上下文深度中的最小值
  result = min(int d | d = computeContextDepth(node, target, type))
}

// 分析不同深度下的指向关系数据
from int marginalFacts, int totalSize, int depthLevel, float efficiencyRatio
where
  // 计算边际事实数：满足最浅深度等于当前深度的(node, target, type)组合数量
  marginalFacts =
    strictcount(ControlFlowNode node, Object target, ClassObject type | 
      depthLevel = computeMinimumDepth(node, target, type)
    ) and
  // 计算总规模：所有指向关系中深度等于当前深度的(node, target, type, ctx, orig)组合数量
  totalSize =
    strictcount(ControlFlowNode node, Object target, ClassObject type, PointsToContext ctx,
      ControlFlowNode orig |
      PointsTo::points_to(node, ctx, target, type, orig) and
      depthLevel = ctx.getDepth()
    ) and
  // 计算效率比例：边际事实数占总规模的百分比
  efficiencyRatio = 100.0 * marginalFacts / totalSize
select depthLevel, marginalFacts, totalSize, efficiencyRatio