/**
 * @name 指向关系分析质量评估
 * @description 本查询通过计算"有价值的分析结果"在"总体分析结果"中的比例，
 * 评估指向关系分析的有效性指标。该指标衡量分析过程的精确度和信息密度，
 * 有助于识别分析引擎的效率，特别是在排除无价值节点（如参数、名称常量和不可变字面量）后的分析质量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

/**
 * 判断控制流节点是否为无分析价值的节点。
 * 无分析价值的节点包括：函数参数、名称常量或不可变字面量。
 */
predicate isTrivialNode(ControlFlowNode node) {
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的质量指标
from 
  int valuableAnalysisCount,    // 有价值的分析结果总数
  int sourceValuableCount,      // 源文件中的有价值分析结果数量
  int totalAnalysisCount,       // 所有指向关系分析结果的总数
  float effectivenessScore      // 分析质量分数
where
  // 计算有价值的分析结果总数（排除无分析价值的节点）
  valuableAnalysisCount =
    strictcount(ControlFlowNode node, Object pointedObject, ClassObject pointedClass |
      node.refersTo(pointedObject, pointedClass, _) and not isTrivialNode(node)
    ) and
  // 计算源文件中的有价值分析结果数量
  sourceValuableCount =
    strictcount(ControlFlowNode node, Object pointedObject, ClassObject pointedClass |
      node.refersTo(pointedObject, pointedClass, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  totalAnalysisCount =
    strictcount(ControlFlowNode node, PointsToContext context, Object pointedObject, 
      ClassObject pointedClass, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, pointedObject, pointedClass, originalNode)
    ) and
  // 计算分析质量分数：源文件有价值分析结果占总体分析结果的百分比
  effectivenessScore = 100.0 * sourceValuableCount / totalAnalysisCount
select valuableAnalysisCount, sourceValuableCount, totalAnalysisCount, effectivenessScore