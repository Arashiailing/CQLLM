/**
 * 分析指向关系在不同上下文深度的分布特征：
 * 1. 计算各深度层级的边际指向事实数（最浅深度对应的唯一三元组）
 * 2. 统计各深度层级的指向关系总规模（包含所有上下文实例）
 * 3. 计算边际事实占比（效率指标）评估上下文敏感性价值
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取指定控制流节点、对象值和类对象在指向关系中的上下文深度
int getContextDepth(ControlFlowNode node, Object target, ClassObject cls) {
  exists(PointsToContext ctx |
    PointsTo::points_to(node, ctx, target, cls, _) and
    result = ctx.getDepth()
  )
}

// 计算给定三元组的最浅上下文深度（所有可能深度的最小值）
int getShallowestDepth(ControlFlowNode node, Object target, ClassObject cls) {
  result = min(int d | d = getContextDepth(node, target, cls))
}

// 按深度层级分析指向关系分布特征
from int depthLevel, 
     int marginalFacts,  // 边际指向事实数（最浅深度唯一三元组）
     int totalRelations,  // 指向关系总规模（含所有上下文）
     float efficiency     // 边际事实占比（效率指标）
where
  // 计算当前深度的边际指向事实数
  marginalFacts = strictcount(ControlFlowNode node, Object target, ClassObject cls |
    depthLevel = getShallowestDepth(node, target, cls)
  ) and
  // 计算当前深度的指向关系总规模
  totalRelations = strictcount(ControlFlowNode node, Object target, ClassObject cls, 
                              PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(node, ctx, target, cls, origin) and
    depthLevel = ctx.getDepth() and
    depthLevel = getShallowestDepth(node, target, cls)  // 确保只统计最浅深度匹配的关系
  ) and
  // 计算边际事实占比（效率指标）
  efficiency = 100.0 * marginalFacts / totalRelations
select depthLevel, marginalFacts, totalRelations, efficiency