/**
 * 衡量指向关系分析的精确度与信息密度。该指标通过计算"有效分析结果"在"全部分析结果"中的占比，
 * 评估分析过程的准确性和信息价值。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为分析价值较低的节点
predicate isLowValueNode(ControlFlowNode node) {
  // 当节点属于以下情况时，认为其分析价值不高：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的精确度指标
from int effectiveResults, int sourceEffectiveResults, int overallResults, float precisionMetric
where
  // 计算有效分析结果总数（排除分析价值较低的节点）
  effectiveResults =
    strictcount(ControlFlowNode node, Object referencedObj, ClassObject targetCls |
      node.refersTo(referencedObj, targetCls, _) and not isLowValueNode(node)
    ) and
  // 计算源文件中的有效分析结果数量
  sourceEffectiveResults =
    strictcount(ControlFlowNode node, Object referencedObj, ClassObject targetCls |
      node.refersTo(referencedObj, targetCls, _) and
      not isLowValueNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  overallResults =
    strictcount(ControlFlowNode node, PointsToContext pointstoContext, Object referencedObj, 
      ClassObject targetCls, ControlFlowNode originalFlowNode | 
      PointsTo::points_to(node, pointstoContext, referencedObj, targetCls, originalFlowNode)
    ) and
  // 计算精确度指标：源文件有效分析结果占全部分析结果的百分比
  precisionMetric = 100.0 * sourceEffectiveResults / overallResults
select effectiveResults, sourceEffectiveResults, overallResults, precisionMetric