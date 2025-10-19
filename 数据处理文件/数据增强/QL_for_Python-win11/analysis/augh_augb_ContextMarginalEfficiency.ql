/**
 * 评估不同上下文深度层级中指向关系的分布模式：
 * 1. 测算各深度层级的边际三元组数量（仅在最浅深度出现的事实）
 * 2. 汇总各深度层级的指向关系总量（考虑所有上下文实例）
 * 3. 计算边际事实比例（性能度量）以衡量上下文敏感性的实际效用
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 提取控制流节点、目标对象及其类在指向分析中的上下文深度值
int retrieveContextDepth(ControlFlowNode cfgNode, Object pointedObject, ClassObject targetClass) {
  exists(PointsToContext contextInfo |
    PointsTo::points_to(cfgNode, contextInfo, pointedObject, targetClass, _) and
    result = contextInfo.getDepth()
  )
}

// 确定指定三元组的最小上下文深度（所有可能深度中的最小值）
int findMinimumDepth(ControlFlowNode cfgNode, Object pointedObject, ClassObject targetClass) {
  result = min(int depthValue | depthValue = retrieveContextDepth(cfgNode, pointedObject, targetClass))
}

// 按深度层级统计指向关系的分布情况
from int contextTier, 
     int uniqueTriplets,  // 边际三元组数量（仅在最浅深度存在）
     int aggregateRelations,  // 指向关系总数（包含所有上下文实例）
     float effectivenessRatio     // 边际事实比例（有效性指标）
where
  // 统计当前深度层级的边际三元组数量
  uniqueTriplets = strictcount(ControlFlowNode cfgNode, Object pointedObject, ClassObject targetClass |
    contextTier = findMinimumDepth(cfgNode, pointedObject, targetClass)
  ) and
  // 计算当前深度层级的指向关系总量
  aggregateRelations = strictcount(ControlFlowNode cfgNode, Object pointedObject, ClassObject targetClass, 
                              PointsToContext contextInfo, ControlFlowNode sourceNode |
    PointsTo::points_to(cfgNode, contextInfo, pointedObject, targetClass, sourceNode) and
    contextTier = contextInfo.getDepth() and
    contextTier = findMinimumDepth(cfgNode, pointedObject, targetClass)  // 限定统计范围至最浅深度匹配的关系
  ) and
  // 计算边际事实比例（有效性指标）
  effectivenessRatio = 100.0 * uniqueTriplets / aggregateRelations
select contextTier, uniqueTriplets, aggregateRelations, effectivenessRatio