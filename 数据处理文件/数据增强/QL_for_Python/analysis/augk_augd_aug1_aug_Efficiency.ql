/**
 * 指向关系分析质量评估。计算有意义分析结果在总体分析结果中的占比，
 * 用于量化分析过程的精确度和信息价值密度。
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
from int meaningfulFactsTotal, int sourceMeaningfulFactsCount, int overallFactsCount, float accuracyMetric
where
  // 统计有意义的分析结果总数（排除无分析价值的节点）
  meaningfulFactsTotal =
    strictcount(ControlFlowNode flowNode, Object referencedObject, ClassObject objectClass |
      flowNode.refersTo(referencedObject, objectClass, _) and not isInsignificantNode(flowNode)
    ) and
  // 统计源文件中的有意义分析结果数量
  sourceMeaningfulFactsCount =
    strictcount(ControlFlowNode flowNode, Object referencedObject, ClassObject objectClass |
      flowNode.refersTo(referencedObject, objectClass, _) and
      not isInsignificantNode(flowNode) and
      exists(flowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 统计所有指向关系分析结果的总数
  overallFactsCount =
    strictcount(ControlFlowNode flowNode, PointsToContext analysisContext, Object referencedObject, 
      ClassObject objectClass, ControlFlowNode originFlowNode | 
      PointsTo::points_to(flowNode, analysisContext, referencedObject, objectClass, originFlowNode)
    ) and
  // 计算质量指标：源文件有意义分析结果占全部分析结果的百分比
  accuracyMetric = 100.0 * sourceMeaningfulFactsCount / overallFactsCount
select meaningfulFactsTotal, sourceMeaningfulFactsCount, overallFactsCount, accuracyMetric