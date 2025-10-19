/**
 * 指向关系分析质量评估。该查询通过计算"有效分析结果"在"全部分析结果"中的比例，
 * 来评估指向关系分析的精确度和信息价值密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为分析价值较低的节点
predicate isLowValueNode(ControlFlowNode node) {
  // 以下类型的节点被视为分析价值较低：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算并选择指向关系分析的质量指标
from int validFactsTotal, int sourceValidFacts, int totalFacts, float analysisQuality
where
  // 计算有效分析结果总数（排除低价值节点）
  validFactsTotal =
    strictcount(ControlFlowNode node, Object refObj, ClassObject cls |
      node.refersTo(refObj, cls, _) and not isLowValueNode(node)
    ) and
  // 计算源文件中的有效分析结果数量
  sourceValidFacts =
    strictcount(ControlFlowNode node, Object refObj, ClassObject cls |
      node.refersTo(refObj, cls, _) and
      not isLowValueNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  totalFacts =
    strictcount(ControlFlowNode node, PointsToContext context, Object refObj, 
      ClassObject cls, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, refObj, cls, originalNode)
    ) and
  // 计算分析质量指标：源文件有效分析结果占全部分析结果的百分比
  analysisQuality = 100.0 * sourceValidFacts / totalFacts
select validFactsTotal, sourceValidFacts, totalFacts, analysisQuality