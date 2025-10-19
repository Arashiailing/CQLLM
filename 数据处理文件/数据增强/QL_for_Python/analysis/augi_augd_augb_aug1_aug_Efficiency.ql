/**
 * 此查询旨在评估指向关系分析的质量指标，通过计算"有效分析结果"在"全部分析结果"中的占比，
 * 来量化分析过程的精确度和信息密度。该指标能够帮助评估分析引擎的性能，尤其是在过滤掉
 * 低价值节点（如参数、名称常量和不可变字面量）后的分析质量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为低价值节点（即分析价值不高的节点）
predicate isTrivialNode(ControlFlowNode flowNode) {
  // 如果节点是以下类型之一，则认为其分析价值有限：函数参数、名称常量或不可变字面量
  flowNode.getNode() instanceof Parameter
  or
  flowNode instanceof NameConstantNode
  or
  flowNode.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的质量指标
from 
  int valuableAnalysisCount,      // 有效分析结果的总数
  int sourceValuableCount,        // 源文件中的有效分析结果数量
  int totalAnalysisCount,         // 所有指向关系分析结果的总数
  float effectivenessScore        // 分析有效性评分
where
  // 计算有效分析结果总数（排除低价值节点）
  valuableAnalysisCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject pointedClass |
      flowNode.refersTo(pointedObject, pointedClass, _) and not isTrivialNode(flowNode)
    ) and
  // 计算源文件中的有效分析结果数量
  sourceValuableCount =
    strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject pointedClass |
      flowNode.refersTo(pointedObject, pointedClass, _) and
      not isTrivialNode(flowNode) and
      exists(flowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  totalAnalysisCount =
    strictcount(ControlFlowNode flowNode, PointsToContext contextInfo, Object pointedObject, 
      ClassObject pointedClass, ControlFlowNode originalFlowNode | 
      PointsTo::points_to(flowNode, contextInfo, pointedObject, pointedClass, originalFlowNode)
    ) and
  // 计算分析有效性评分：源文件有效分析结果占总体分析结果的百分比
  effectivenessScore = 100.0 * sourceValuableCount / totalAnalysisCount
select valuableAnalysisCount, sourceValuableCount, totalAnalysisCount, effectivenessScore