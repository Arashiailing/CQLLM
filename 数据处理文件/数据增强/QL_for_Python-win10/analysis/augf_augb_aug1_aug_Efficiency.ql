/**
 * 衡量指向分析的质量评估。此指标通过计算"有效分析结果"在"全部分析结果"中的占比，
 * 来评估分析过程的准确性和信息价值密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 识别控制流节点是否为低信息价值节点
predicate isLowValueNode(ControlFlowNode flowNode) {
  // 当节点符合以下条件时，认为其信息价值较低：函数参数、名称常量或不可变字面量
  flowNode.getNode() instanceof Parameter
  or
  flowNode instanceof NameConstantNode
  or
  flowNode.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的精确度指标
from int significantResults, int sourceSignificantResults, int overallResults, float precisionMetric
where
  // 计算有效分析结果总量（排除低信息价值节点）
  significantResults =
    strictcount(ControlFlowNode flowNode, Object referencedEntity, ClassObject targetClass |
      flowNode.refersTo(referencedEntity, targetClass, _) and not isLowValueNode(flowNode)
    ) and
  // 计算源代码文件中的有效分析结果数量
  sourceSignificantResults =
    strictcount(ControlFlowNode flowNode, Object referencedEntity, ClassObject targetClass |
      flowNode.refersTo(referencedEntity, targetClass, _) and
      not isLowValueNode(flowNode) and
      exists(flowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总和
  overallResults =
    strictcount(ControlFlowNode flowNode, PointsToContext pointsToContext, Object referencedEntity, 
      ClassObject targetClass, ControlFlowNode originFlowNode | 
      PointsTo::points_to(flowNode, pointsToContext, referencedEntity, targetClass, originFlowNode)
    ) and
  // 计算分析精确度分数：源文件有效分析结果占全部分析结果的百分比
  precisionMetric = 100.0 * sourceSignificantResults / overallResults
select significantResults, sourceSignificantResults, overallResults, precisionMetric