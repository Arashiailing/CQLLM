/**
 * 指向关系分析精确度量化评估。此查询旨在评估代码分析引擎在识别对象引用关系时的准确性，
 * 通过计算有意义的分析结果在总体结果中的占比，为分析质量提供可量化的度量标准。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为无分析价值的类型
// 此类节点通常不包含有价值的引用信息，如函数参数、常量或不可变字面量
predicate isUninterestingNode(ControlFlowNode node) {
  // 以下类型的节点被认为不包含有价值的引用信息：
  node.getNode() instanceof Parameter    // 函数参数
  or
  node instanceof NameConstantNode       // 名称常量
  or
  node.getNode() instanceof ImmutableLiteral  // 不可变字面量
}

// 计算指向关系分析的各项质量指标
from int meaningfulAnalysisCount, int sourceFileMeaningfulCount, int overallAnalysisResults, float precisionEvaluationMetric
where
  // 计算有意义的分析结果总数（排除无价值节点）
  meaningfulAnalysisCount =
    strictcount(ControlFlowNode controlFlowNode, Object pointedToObject, ClassObject destinationClass |
      controlFlowNode.refersTo(pointedToObject, destinationClass, _) and not isUninterestingNode(controlFlowNode)
    ) and
  // 计算源文件中有意义的分析结果数量
  sourceFileMeaningfulCount =
    strictcount(ControlFlowNode controlFlowNode, Object pointedToObject, ClassObject destinationClass |
      controlFlowNode.refersTo(pointedToObject, destinationClass, _) and
      not isUninterestingNode(controlFlowNode) and
      exists(controlFlowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  overallAnalysisResults =
    strictcount(ControlFlowNode controlFlowNode, PointsToContext pointingContext, Object pointedToObject, 
      ClassObject destinationClass, ControlFlowNode originControlFlowNode | 
      PointsTo::points_to(controlFlowNode, pointingContext, pointedToObject, destinationClass, originControlFlowNode)
    ) and
  // 计算精确度评估指标：源文件中有意义分析结果占总结果的百分比
  precisionEvaluationMetric = 100.0 * sourceFileMeaningfulCount / overallAnalysisResults
select meaningfulAnalysisCount, sourceFileMeaningfulCount, overallAnalysisResults, precisionEvaluationMetric