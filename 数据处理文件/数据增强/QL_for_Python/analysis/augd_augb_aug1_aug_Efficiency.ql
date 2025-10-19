/**
 * 本查询评估指向关系分析的有效性指标，通过计算"有价值的分析结果"在"总体分析结果"中的比例，
 * 来衡量分析过程的精确度和信息密度。该指标有助于识别分析引擎的效率，特别是在排除无价值节点
 * （如参数、名称常量和不可变字面量）后的分析质量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为无分析价值的节点
predicate isTrivialNode(ControlFlowNode controlNode) {
  // 当节点属于以下情况时，认为其分析价值较低：函数参数、名称常量或不可变字面量
  controlNode.getNode() instanceof Parameter
  or
  controlNode instanceof NameConstantNode
  or
  controlNode.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的质量指标
from 
  int significantAnalysisResults,    // 有价值的分析结果总数
  int sourceSignificantResults,      // 源文件中的有价值分析结果数量
  int overallAnalysisResults,        // 所有指向关系分析结果的总数
  float analysisEffectivenessMetric  // 分析质量分数
where
  // 计算有价值的分析结果总数（排除无分析价值的节点）
  significantAnalysisResults =
    strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject targetClass |
      controlNode.refersTo(targetObject, targetClass, _) and not isTrivialNode(controlNode)
    ) and
  // 计算源文件中的有价值分析结果数量
  sourceSignificantResults =
    strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject targetClass |
      controlNode.refersTo(targetObject, targetClass, _) and
      not isTrivialNode(controlNode) and
      exists(controlNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  overallAnalysisResults =
    strictcount(ControlFlowNode controlNode, PointsToContext pointingContext, Object targetObject, 
      ClassObject targetClass, ControlFlowNode originalControlNode | 
      PointsTo::points_to(controlNode, pointingContext, targetObject, targetClass, originalControlNode)
    ) and
  // 计算分析质量分数：源文件有价值分析结果占总体分析结果的百分比
  analysisEffectivenessMetric = 100.0 * sourceSignificantResults / overallAnalysisResults
select significantAnalysisResults, sourceSignificantResults, overallAnalysisResults, analysisEffectivenessMetric