/**
 * 评估指向关系分析的有效性指标。该指标通过计算"有价值的分析结果"在"总体分析结果"中的比例，
 * 来衡量分析过程的精确度和信息密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为无分析价值的节点
predicate isTrivialNode(ControlFlowNode node) {
  // 当节点属于以下情况时，认为其分析价值较低：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的质量指标
from int valuableAnalysisResults, int sourceValuableResults, int totalAnalysisResults, float analysisQualityScore
where
  // 计算有价值的分析结果总数（排除无分析价值的节点）
  valuableAnalysisResults =
    strictcount(ControlFlowNode node, Object referencedObj, ClassObject targetCls |
      node.refersTo(referencedObj, targetCls, _) and not isTrivialNode(node)
    ) and
  // 计算源文件中的有价值分析结果数量
  sourceValuableResults =
    strictcount(ControlFlowNode node, Object referencedObj, ClassObject targetCls |
      node.refersTo(referencedObj, targetCls, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  totalAnalysisResults =
    strictcount(ControlFlowNode node, PointsToContext pointstoContext, Object referencedObj, 
      ClassObject targetCls, ControlFlowNode originalFlowNode | 
      PointsTo::points_to(node, pointstoContext, referencedObj, targetCls, originalFlowNode)
    ) and
  // 计算分析质量分数：源文件有价值分析结果占总体分析结果的百分比
  analysisQualityScore = 100.0 * sourceValuableResults / totalAnalysisResults
select valuableAnalysisResults, sourceValuableResults, totalAnalysisResults, analysisQualityScore