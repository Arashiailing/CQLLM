/**
 * 评估指向关系分析结果的质量度量标准。该指标通过计算"有价值的分析发现"在"总体分析结果"中的比例，
 * 来衡量分析过程的精确度和信息密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 识别控制流节点中不具备分析价值的谓词
predicate isTrivialNode(ControlFlowNode node) {
  // 当节点为以下类型时，认为其分析价值较低：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算并输出指向关系分析的质量度量
from int significantFactsTotal, int sourceSignificantFactsCount, int totalAnalysisResults, float analysisQualityScore
where
  // 计算有价值的分析结果总量（排除无价值节点）
  significantFactsTotal =
    strictcount(ControlFlowNode node, Object targetObject, ClassObject destinationClass |
      node.refersTo(targetObject, destinationClass, _) and not isTrivialNode(node)
    ) and
  // 计算源文件中有价值的分析结果数量
  sourceSignificantFactsCount =
    strictcount(ControlFlowNode node, Object targetObject, ClassObject destinationClass |
      node.refersTo(targetObject, destinationClass, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算指向关系分析结果的总数
  totalAnalysisResults =
    strictcount(ControlFlowNode node, PointsToContext pointContext, Object targetObject, 
      ClassObject destinationClass, ControlFlowNode sourceNode | 
      PointsTo::points_to(node, pointContext, targetObject, destinationClass, sourceNode)
    ) and
  // 计算分析质量分数：源文件中有价值结果占总分析结果的百分比
  analysisQualityScore = 100.0 * sourceSignificantFactsCount / totalAnalysisResults
select significantFactsTotal, sourceSignificantFactsCount, totalAnalysisResults, analysisQualityScore