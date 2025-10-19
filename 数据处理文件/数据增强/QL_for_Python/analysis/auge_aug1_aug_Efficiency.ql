/**
 * 指向关系分析质量评估。该查询通过计算"有效分析结果"在"总体分析结果"中的比例，
 * 来评估指向关系分析的精确度和信息密度，为分析质量提供量化指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否属于无分析价值的类型
// 这些节点通常不包含有价值的指向关系信息，如参数、常量或不可变字面量
predicate isTrivialNode(ControlFlowNode node) {
  // 以下类型的节点被视为无分析价值：
  node.getNode() instanceof Parameter    // 函数参数
  or
  node instanceof NameConstantNode       // 名称常量
  or
  node.getNode() instanceof ImmutableLiteral  // 不可变字面量
}

// 计算指向关系分析的各项质量指标
from int significantFactsTotal, int sourceSignificantFacts, int totalAnalysisResults, float analysisQualityScore
where
  // 1. 计算有效分析结果总数（排除无价值的节点）
  significantFactsTotal =
    strictcount(ControlFlowNode node, Object refObj, ClassObject tgtClass |
      node.refersTo(refObj, tgtClass, _) and not isTrivialNode(node)
    ) and
  // 2. 计算源文件中的有效分析结果数量
  sourceSignificantFacts =
    strictcount(ControlFlowNode node, Object refObj, ClassObject tgtClass |
      node.refersTo(refObj, tgtClass, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 3. 计算所有指向关系分析结果的总数
  totalAnalysisResults =
    strictcount(ControlFlowNode node, PointsToContext context, Object refObj, 
      ClassObject tgtClass, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, refObj, tgtClass, originalNode)
    ) and
  // 4. 计算分析质量得分：源文件有效分析结果占总体结果的百分比
  analysisQualityScore = 100.0 * sourceSignificantFacts / totalAnalysisResults
select significantFactsTotal, sourceSignificantFacts, totalAnalysisResults, analysisQualityScore