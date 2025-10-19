/**
 * 指向关系分析精确度量化评估。该查询通过测量"有效分析结果"在"总分析结果"中的比例，
 * 来评估指向关系分析的精确度与信息密度，为分析质量提供可量化的性能指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判定控制流节点是否属于无分析价值的类型
// 此类节点通常不包含有意义的指向关系信息，例如参数、常量或不可变字面量
predicate isTrivialNode(ControlFlowNode node) {
  // 以下节点类型被视为无分析价值：
  node.getNode() instanceof Parameter    // 函数参数
  or
  node instanceof NameConstantNode       // 名称常量
  or
  node.getNode() instanceof ImmutableLiteral  // 不可变字面量
}

// 计算指向关系分析的质量评估指标
from int significantAnalysisCount, int sourceSignificantAnalysisCount, int totalAnalysisResults, float analysisPrecisionMetric
where
  // 计算有效分析结果总数（过滤掉无价值节点）
  significantAnalysisCount =
    strictcount(ControlFlowNode cfNode, Object referencedObject, ClassObject targetClass |
      cfNode.refersTo(referencedObject, targetClass, _) and not isTrivialNode(cfNode)
    ) and
  // 计算源文件中的有效分析结果数量
  sourceSignificantAnalysisCount =
    strictcount(ControlFlowNode cfNode, Object referencedObject, ClassObject targetClass |
      cfNode.refersTo(referencedObject, targetClass, _) and
      not isTrivialNode(cfNode) and
      exists(cfNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  totalAnalysisResults =
    strictcount(ControlFlowNode cfNode, PointsToContext pointsToContext, Object referencedObject, 
      ClassObject targetClass, ControlFlowNode originCfNode | 
      PointsTo::points_to(cfNode, pointsToContext, referencedObject, targetClass, originCfNode)
    ) and
  // 计算精确度度量：源文件中有效分析结果占总体结果的百分比
  analysisPrecisionMetric = 100.0 * sourceSignificantAnalysisCount / totalAnalysisResults
select significantAnalysisCount, sourceSignificantAnalysisCount, totalAnalysisResults, analysisPrecisionMetric