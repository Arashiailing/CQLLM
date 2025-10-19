/**
 * 指向关系分析精确度评估。本查询通过量化"有价值分析结果"在"全部分析结果"中的占比，
 * 评估指向关系分析的精确度和信息密度，提供分析质量的量化度量指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为无分析价值的类型
// 此类节点通常不包含有意义的指向关系信息，如参数、常量或不可变字面量
predicate isTrivialNode(ControlFlowNode node) {
  // 以下节点类型被归类为无分析价值：
  node.getNode() instanceof Parameter    // 函数参数
  or
  node instanceof NameConstantNode       // 名称常量
  or
  node.getNode() instanceof ImmutableLiteral  // 不可变字面量
}

// 计算指向关系分析的质量评估指标
from int valuableAnalysisCount, int sourceValuableAnalysisCount, int overallAnalysisResults, float precisionMetric
where
  // 计算有价值的分析结果总数（排除无价值的节点）
  valuableAnalysisCount =
    strictcount(ControlFlowNode node, Object refObj, ClassObject tgtClass |
      node.refersTo(refObj, tgtClass, _) and not isTrivialNode(node)
    ) and
  // 计算源文件中的有价值分析结果数量
  sourceValuableAnalysisCount =
    strictcount(ControlFlowNode node, Object refObj, ClassObject tgtClass |
      node.refersTo(refObj, tgtClass, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  overallAnalysisResults =
    strictcount(ControlFlowNode node, PointsToContext context, Object refObj, 
      ClassObject tgtClass, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, refObj, tgtClass, originalNode)
    ) and
  // 计算精确度度量：源文件中有价值分析结果占总体结果的百分比
  precisionMetric = 100.0 * sourceValuableAnalysisCount / overallAnalysisResults
select valuableAnalysisCount, sourceValuableAnalysisCount, overallAnalysisResults, precisionMetric