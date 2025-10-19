/**
 * 衡量指向关系分析的质量指标。通过计算"有意义的分析结果"在"全部分析结果"中的占比，
 * 评估分析过程的精确度和信息价值密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为无分析价值的谓词
predicate isInsignificantNode(ControlFlowNode flowNode) {
  // 节点属于以下情况时视为无分析价值：函数参数、名称常量或不可变字面量
  flowNode.getNode() instanceof Parameter
  or
  flowNode instanceof NameConstantNode
  or
  flowNode.getNode() instanceof ImmutableLiteral
}

// 计算并选择指向关系分析的质量指标
from int meaningfulFactsCount, int sourceMeaningfulFactsCount, int overallFactsCount, float qualityMetric
where
  // 统计有意义的分析结果总数（排除无分析价值的节点）
  meaningfulFactsCount =
    strictcount(ControlFlowNode flowNode, Object referencedObject, ClassObject targetClass |
      flowNode.refersTo(referencedObject, targetClass, _) and not isInsignificantNode(flowNode)
    ) and
  // 统计源文件中的有意义分析结果数量
  sourceMeaningfulFactsCount =
    strictcount(ControlFlowNode flowNode, Object referencedObject, ClassObject targetClass |
      flowNode.refersTo(referencedObject, targetClass, _) and
      not isInsignificantNode(flowNode) and
      exists(flowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 统计所有指向关系分析结果的总数
  overallFactsCount =
    strictcount(ControlFlowNode flowNode, PointsToContext context, Object referencedObject, 
      ClassObject targetClass, ControlFlowNode originalNode | 
      PointsTo::points_to(flowNode, context, referencedObject, targetClass, originalNode)
    ) and
  // 计算质量指标：源文件有意义分析结果占全部分析结果的百分比
  qualityMetric = 100.0 * sourceMeaningfulFactsCount / overallFactsCount
select meaningfulFactsCount, sourceMeaningfulFactsCount, overallFactsCount, qualityMetric