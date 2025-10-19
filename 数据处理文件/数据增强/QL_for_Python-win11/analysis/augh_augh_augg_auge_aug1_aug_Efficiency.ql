/**
 * 指向关系分析精确度量化评估。本查询通过测量"有效分析结果"在"总分析结果"中的占比，
 * 量化评估指向关系分析的精确度与信息密度，为分析质量提供可量化的性能指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判定控制流节点是否属于无分析价值的类型
// 此类节点通常不包含有意义的指向关系信息，如参数、常量或不可变字面量
predicate isInsignificantNode(ControlFlowNode node) {
  // 以下节点类型被视为无分析价值：
  node.getNode() instanceof Parameter    // 函数参数
  or
  node instanceof NameConstantNode       // 名称常量
  or
  node.getNode() instanceof ImmutableLiteral  // 不可变字面量
}

// 计算指向关系分析的质量评估指标
from int meaningfulAnalysisCount, int sourceMeaningfulAnalysisCount, int overallAnalysisResults, float analysisAccuracyMetric
where
  // 计算有效分析结果总数（过滤掉无价值节点）
  meaningfulAnalysisCount =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject destinationClass |
      controlFlowNode.refersTo(pointedObject, destinationClass, _) and not isInsignificantNode(controlFlowNode)
    ) and
  // 计算源文件中的有效分析结果数量
  sourceMeaningfulAnalysisCount =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject destinationClass |
      controlFlowNode.refersTo(pointedObject, destinationClass, _) and
      not isInsignificantNode(controlFlowNode) and
      exists(controlFlowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  overallAnalysisResults =
    strictcount(ControlFlowNode controlFlowNode, PointsToContext pointsToContext, Object pointedObject, 
      ClassObject destinationClass, ControlFlowNode originControlFlowNode | 
      PointsTo::points_to(controlFlowNode, pointsToContext, pointedObject, destinationClass, originControlFlowNode)
    ) and
  // 计算精确度度量：源文件中有效分析结果占总体结果的百分比
  analysisAccuracyMetric = 100.0 * sourceMeaningfulAnalysisCount / overallAnalysisResults
select meaningfulAnalysisCount, sourceMeaningfulAnalysisCount, overallAnalysisResults, analysisAccuracyMetric